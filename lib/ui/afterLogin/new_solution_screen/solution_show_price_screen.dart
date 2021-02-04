import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_painter_icon_gen.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/solution_blocs/search_solution_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/booking_screens/booking_main_screen.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/show_insurance_list_screen.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/solution_map_screen.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'package:syncfusion_flutter_gauges/gauges.dart';

// ignore: must_be_immutable
class SolutionShowPriceScreen extends BaseActivity {
  final String searchQuery;
  final CatalogueData catalogueData;

  SolutionShowPriceScreen({this.catalogueData, this.searchQuery});

  @override
  _SolutionShowPriceScreenState createState() =>
      _SolutionShowPriceScreenState();
}

class _SolutionShowPriceScreenState extends BaseState<SolutionShowPriceScreen> {
  IconGenerator _iconGen;
  BitmapDescriptor hosImage2XGreenBgDesc;
  Set<Marker> _markers = {};
  SearchSolutionBloc _searchSolutionBloc;
  SearchedDocResults _searchedDocResults;
  List<Widget> _mapWidgets;
  List<GlobalKey> _globalKeys = [];
  List<Function> _functions = [];
  List<Services> _customServices = [];
  String _failedMessage;
  GoogleMapController _mapController;
  Completer<GoogleMapController> _googleMapController = Completer();
  User _user;
  DocHosSolution _solution;
  StreamController _totalDiscountController;
  num _gainedDiscount = 0, _gainedDiscountPercentage = 0;
  Timer _discountCalculationTimer;

  @override
  void initState() {
    _totalDiscountController = StreamController.broadcast();
    _user = UserManager().getUserDetails();
    _mapWidgets = [];
    _markers = {};
    _iconGen = IconGenerator();
    _searchSolutionBloc = SearchSolutionBloc();
    _getFacilities();
    _discountCalculationTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      _discountCalculationTimer = timer;
      _getTotalDiscount();
    });
    _iconGen
        .getBytesFromAsset(PlunesImages.hosImage2XGreenBg, 180)
        .then((value) {
      hosImage2XGreenBgDesc = BitmapDescriptor.fromBytes(value);
      // _markers.add(Marker(
      //     icon: hosImage2XGreenBgDesc,
      //     position: LatLng(28.443, 78.3222),
      //     markerId: MarkerId("ds"),
      //     onTap: () => _doSomething()));
      // if (mounted) setState(() {});
    });
    super.initState();
  }

  num _getTotalDiscount() {
    num totalDiscount = 0, _origPrice = 0, _highestDiscount = 0;
    try {
      if (_searchedDocResults != null &&
          _searchedDocResults.solution != null &&
          _searchedDocResults.solution.services != null &&
          _searchedDocResults.solution.services.isNotEmpty) {
        _searchedDocResults.solution.services.forEach((service) {
          if (service.doctors != null && service.doctors.isNotEmpty) {
            service.doctors.forEach((element) {
              if (element.discount != null && element.discount > 0) {
                if (((element.price[0] - element.newPrice[0])) >
                    _highestDiscount) {
                  _highestDiscount = (element.price[0] - element.newPrice[0]);
                  _origPrice = element.price[0];
                }
              }
            });
          } else {
            if (service.discount != null && service.discount > 0) {
              if ((service.price[0] - service.newPrice[0]) > _highestDiscount) {
                _highestDiscount = (service.price[0] - service.newPrice[0]);
                _origPrice = service.price[0];
              }
            }
          }
        });
      }
    } catch (e) {
//      print("error in _getTotalDiscount ${e.toString()}");
      totalDiscount = 0;
    }
    _gainedDiscount = _highestDiscount;
    if (_origPrice != null &&
        _origPrice > 0 &&
        _gainedDiscount != null &&
        _gainedDiscount > 0) {
      _gainedDiscountPercentage = double.tryParse(
          ((_gainedDiscount / _origPrice) * 100)?.toStringAsFixed(0));
      _totalDiscountController.add(null);
    }
    totalDiscount = _gainedDiscount;
    return totalDiscount;
  }

  @override
  void dispose() {
    _globalKeys = [];
    _functions = [];
    _customServices = [];
    _searchSolutionBloc?.dispose();
    _totalDiscountController?.close();
    _discountCalculationTimer?.cancel();
    super.dispose();
  }

  void _getFacilities() {
    _searchSolutionBloc.getDocHosSolution(widget.catalogueData,
        searchQuery: widget.searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<RequestState>(
          stream: _searchSolutionBloc.getDocHosStream(),
          initialData:
              (_searchedDocResults == null) ? RequestInProgress() : null,
          builder: (context, snapshot) {
            if (snapshot.data is RequestInProgress) {
              return CustomWidgets().getProgressIndicator();
            } else if (snapshot.data is RequestSuccess) {
              RequestSuccess data = snapshot.data;
              _searchedDocResults = data.response;
              _calculateMapData();
              _searchSolutionBloc.addIntoDocHosStream(null);
            } else if (snapshot.data is RequestFailed) {
              RequestFailed _reqFailObj = snapshot.data;
              _failedMessage = _reqFailObj?.failureCause;
              _searchSolutionBloc.addIntoDocHosStream(null);
            }
            return (_searchedDocResults == null ||
                    (_searchedDocResults.success != null &&
                        !_searchedDocResults.success) ||
                    _searchedDocResults.solution == null ||
                    _searchedDocResults.solution.services == null ||
                    _searchedDocResults.solution.services.isEmpty)
                ? CustomWidgets().errorWidget(
                    _failedMessage ?? _searchedDocResults?.msg,
                    onTap: () => _getFacilities(),
                    isSizeLess: true)
                : SafeArea(
                    child: AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle.dark,
                      child: Scaffold(
                        backgroundColor: PlunesColors.WHITECOLOR,
                        key: scaffoldKey,
                        appBar: _getAppBar(),
                        body: _getBody(),
                      ),
                    ),
                    top: false,
                    bottom: false,
                  );
          }),
    );
  }

  PreferredSize _getAppBar() {
    String value = "Valid for 1 hour only";
    return PreferredSize(
        child: Card(
            color: Colors.white,
            elevation: 3.0,
            margin: EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
            child: Stack(
              children: [
                ListTile(
                  leading: Container(
                      padding: EdgeInsets.all(0),
                      child: IconButton(
                        alignment: Alignment.bottomCenter,
                        onPressed: () {
                          Navigator.pop(context, false);
                          return;
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      )),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      PlunesStrings.negotiatedSolutions,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR, fontSize: 16),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          PlunesImages.validForOneHourOnlyWatch,
                          scale: 3,
                        ),
                        Padding(
                          child: RichText(
                            text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "7 days" ?? "",
                                      style: TextStyle(
                                          color: PlunesColors.GREENCOLOR,
                                          fontSize: 16)),
                                  TextSpan(
                                      text: " only",
                                      style: TextStyle(
                                          color: PlunesColors.GREYCOLOR,
                                          fontSize: 15)),
                                ],
                                text: PlunesStrings.validForOneHour,
                                style: TextStyle(
                                    color: PlunesColors.GREYCOLOR,
                                    fontSize: 15)),
                          ),
                          padding: EdgeInsets.only(left: 4.0),
                        )
                      ],
                    )
                  ],
                )
              ],
            )),
        preferredSize: Size(double.infinity, AppConfig.verticalBlockSize * 8));
  }

  Widget _getNegotiatedPriceTotalView() {
    return StreamBuilder(
      builder: (context, data) {
        if (_gainedDiscount == null || _gainedDiscount == 0) {
          return Container();
        }
        String time = "NA";
        var duration = DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(
                _searchedDocResults?.solution?.expirationTimer ?? 0));
        if (duration.inHours < 24 && duration.inHours >= 1) {
          time =
              "${duration.inHours} ${duration.inHours == 1 ? "hour" : "hours"}";
        } else if (duration.inHours >= 24) {
          time = "${duration.inDays} ${duration.inDays == 1 ? "day" : "days"}";
        } else if (duration.inMinutes < 1) {
          time = "${duration.inSeconds} secs";
        } else {
          time =
              "${duration.inMinutes} ${duration.inMinutes == 1 ? "min" : "mins"}";
        }
        return Container(
          margin: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 4,
              right: AppConfig.horizontalBlockSize * 4,
              top: AppConfig.verticalBlockSize * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Container(
                  child: Image.asset(PlunesImages.savedMoneyImage),
                  height: AppConfig.verticalBlockSize * 4,
                  width: AppConfig.horizontalBlockSize * 10,
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 2.0)),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "We managed to save ",
                      style: TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontWeight: FontWeight.normal,
                          fontSize: 16),
                      children: [
                        TextSpan(
                            text:
                                "\u20B9${_gainedDiscount?.toStringAsFixed(0)} ",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal,
                                fontSize: 16)),
                        TextSpan(
                            text: "for you in last ",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal,
                                fontSize: 16)),
                        TextSpan(
                            text: "$time !",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal,
                                fontSize: 16))
                      ]))
            ],
          ),
        );
      },
      stream: _totalDiscountController.stream,
      initialData: _gainedDiscount,
    );
  }

  Widget _getBody() {
    return Stack(
      children: [
        Container(child: ListView(children: _mapWidgets ?? [])),
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        ),
        Container(
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: (mapController) {
                  if (_googleMapController != null &&
                      _googleMapController.isCompleted) {
                    return;
                  }
                  _mapController = mapController;
                  _googleMapController.complete(_mapController);
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(double.parse(_user.latitude),
                        double.parse(_user.longitude)),
                    zoom: 10),
                zoomControlsEnabled: false,
                padding: EdgeInsets.all(0.0),
                myLocationEnabled: false,
                zoomGesturesEnabled: true,
                myLocationButtonEnabled: false,
                buildingsEnabled: false,
                trafficEnabled: false,
                indoorViewEnabled: false,
                mapType: MapType.terrain,
                markers: _markers,
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.3,
                  maxChildSize: 0.9,
                  builder: (context, controller) {
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppConfig.horizontalBlockSize * 1.2,
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35))),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: AppConfig.horizontalBlockSize * 3.8,
                            vertical: AppConfig.verticalBlockSize * 2.8),
                        child: ListView(
                          controller: controller,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: AppConfig.verticalBlockSize * 2.8,
                                  left: AppConfig.horizontalBlockSize * 38,
                                  right: AppConfig.horizontalBlockSize * 38),
                              height: 3,
                              decoration: BoxDecoration(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#707070")),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                            _getNegotiatedPriceTotalView(),
                            StreamBuilder<Object>(
                                stream: _totalDiscountController?.stream,
                                builder: (context, snapshot) {
                                  if (_gainedDiscountPercentage == null ||
                                      _gainedDiscountPercentage <= 0) {
                                    return Container();
                                  }
                                  return _getDialerWidget();
                                }),
                            _getTypeOfFacilityWidget(),
                            _getFacilityDefinitionWidget(),
                            _getProfessionalListWidget(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _getProfessionalListWidget() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (_searchedDocResults.solution.services[index].doctors != null &&
              _searchedDocResults.solution.services[index].doctors.isNotEmpty) {
            return _getHospitalDoctorListWidget(
                _searchedDocResults.solution.services[index]);
          }
          return CommonWidgets().getBookProfessionalWidget(
              _searchedDocResults.solution.services[index],
              () => _openProfile(_searchedDocResults.solution.services[index]),
              () => _bookFacilityAppointment(
                  _searchedDocResults.solution.services[index]),
              () => _openInsuranceScreen(
                  _searchedDocResults.solution.services[index]));
        },
        itemCount: _searchedDocResults?.solution?.services?.length ?? 0,
      ),
    );
  }

  Widget _getTypeOfFacilityWidget() {
    return Card(
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shadowColor: Color(CommonMethods.getColorHexFromStr("#00000029")),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 2,
          top: AppConfig.verticalBlockSize * 2),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 5.9,
            vertical: AppConfig.verticalBlockSize * 1.8),
        child: Row(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                _searchedDocResults?.catalogueData?.service ?? "",
                style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 16),
              ),
            )),
            Expanded(
              child: Container(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onDoubleTap: () {},
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SolutionMap(
                                    _searchedDocResults, widget.catalogueData)))
                        .then((value) {
                      if (value != null && value) {
                        Navigator.pop(context, true);
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        PlunesStrings.viewOnMap,
                        style: TextStyle(
                            color: PlunesColors.GREENCOLOR, fontSize: 16),
                      ),
                      Container(
                        height: AppConfig.verticalBlockSize * 3,
                        width: AppConfig.horizontalBlockSize * 5,
                        child: Image.asset(plunesImages.locationIcon),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getFacilityDefinitionWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.5),
            child: Text(
              "Definition",
              style: TextStyle(
                  fontSize: 14,
                  color: PlunesColors.BLACKCOLOR,
                  fontWeight: FontWeight.normal),
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
                  child: ReadMoreText(
                    _searchedDocResults?.catalogueData?.details ?? "",
                    colorClickableText: PlunesColors.SPARKLINGGREEN,
                    trimLines: 3,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: '  ...read more',
                    trimExpandedText: '  read less',
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            Color(CommonMethods.getColorHexFromStr("#515151")),
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 2,
                bottom: AppConfig.verticalBlockSize * 2),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _searchedDocResults?.catalogueData?.duration ??
                                "Depends on case",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14,
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal),
                          ),
                          Text(
                            "Duration",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#515151")),
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _searchedDocResults?.catalogueData?.sitting ??
                                "Depends on case",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14,
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal),
                          ),
                          Text(
                            "Session",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#515151")),
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _calculateMapData() async {
    await Future.delayed(Duration(milliseconds: 20));
    if (_searchedDocResults != null &&
        _searchedDocResults.solution != null &&
        _searchedDocResults.solution.services != null &&
        _searchedDocResults.solution.services.isNotEmpty) {
      _globalKeys = [];
      _mapWidgets = [];
      _functions = [];
      _customServices = [];
      for (int index = 0;
          index < _searchedDocResults.solution.services.length;
          index++) {
        if (_searchedDocResults.solution.services[index].doctors != null &&
            _searchedDocResults.solution.services[index].doctors.isNotEmpty) {
          _searchedDocResults.solution.services[index].doctors
              .forEach((doctor) {
            var key = GlobalKey();
            _globalKeys.add(key);
            _functions.add(() => _showHospitalDoctorPopup(
                _searchedDocResults.solution.services[index],
                widget.catalogueData,
                () =>
                    _openProfile(_searchedDocResults.solution.services[index]),
                _searchedDocResults.solution.services[index].doctors
                    .indexOf(doctor)));
            Services service = Services(
                name: doctor?.name ?? "",
                sId: _searchedDocResults.solution.services[index].sId,
                latitude: _searchedDocResults.solution.services[index].latitude,
                longitude:
                    _searchedDocResults.solution.services[index].longitude,
                distance:
                    _searchedDocResults.solution.services[index].distance);
            _customServices.add(service);
            _mapWidgets.add(RepaintBoundary(
              child: Container(
                child: (1 == 1)
                    ? Row(
                        children: [
                          Expanded(child: Container()),
                          Container(
                            padding: EdgeInsets.all(11),
                            decoration: BoxDecoration(
                                color: PlunesColors.WHITECOLOR,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18)),
                                border: Border.all(
                                    width: 0.9,
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            "#70707038")))),
                            child: Text(
                              "\u20B9 ${doctor?.newPrice?.first?.toStringAsFixed(1) ?? "0.0"}",
                              style: TextStyle(
                                  color: PlunesColors.BLACKCOLOR, fontSize: 18),
                            ),
                          ),
                          Expanded(child: Container()),
                        ],
                      )
                    : Column(
                        children: [
                          ClipOval(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle),
                              child: CustomWidgets().getImageFromUrl(
                                  doctor.imageUrl ?? "",
                                  placeHolderPath: PlunesImages.labMapImage,
                                  boxFit: BoxFit.fill),
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.indigo.withOpacity(0.4)),
                          )
                        ],
                      ),
              ),
              key: key,
            ));
          });
        } else {
          var key = GlobalKey();
          _globalKeys.add(key);
          _functions.add(() => _showProfessionalPopup(
              _searchedDocResults.solution.services[index],
              widget.catalogueData,
              () =>
                  _openProfile(_searchedDocResults.solution.services[index])));
          _customServices.add(_searchedDocResults.solution.services[index]);
          _mapWidgets.add(RepaintBoundary(
            child: Container(
              child: (1 == 1)
                  ? Row(
                      children: [
                        Expanded(child: Container()),
                        Container(
                          padding: EdgeInsets.all(11),
                          decoration: BoxDecoration(
                              color: PlunesColors.WHITECOLOR,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                              border: Border.all(
                                  width: 0.9,
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      "#70707038")))),
                          child: Text(
                            "\u20B9 ${_searchedDocResults.solution?.services[index]?.newPrice?.first?.toStringAsFixed(1) ?? "0.0"}",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR, fontSize: 18),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        )
                      ],
                    )
                  : Column(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle),
                            child: CustomWidgets().getImageFromUrl(
                                _searchedDocResults
                                    .solution.services[index].imageUrl,
                                placeHolderPath: PlunesImages.labMapImage,
                                boxFit: BoxFit.fill),
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.indigo.withOpacity(0.4)),
                        )
                      ],
                    ),
            ),
            key: key,
          ));
        }
      }
      _showMapWidgetsAfterDelay();
    }
  }

  void _showMapWidgetsAfterDelay() async {
    try {
      double minZoom = 0;
      int arrLength = _searchedDocResults.solution.services.length;
      for (int index = 0; index < arrLength; index++) {
        if (_searchedDocResults.solution.services[index].distance != null &&
            _searchedDocResults.solution.services[index].distance > minZoom) {
          minZoom = _searchedDocResults.solution.services[index].distance;
        }
      }
      if (minZoom != 0) {
        _animateMapPosition(minZoom);
      }
      await Future.delayed(Duration(seconds: 1));
      for (int index = 0; index < _globalKeys.length; index++) {
        RenderRepaintBoundary boundary =
            _globalKeys[index].currentContext.findRenderObject();
        var image = await boundary?.toImage(pixelRatio: 2.0);
        ByteData byteData =
            await image?.toByteData(format: ui.ImageByteFormat.png);
        var bytes = byteData.buffer.asUint8List();
        // print("bytes are $bytes");
        await Future.delayed(Duration(milliseconds: 150));
        _markers.add(Marker(
            markerId: MarkerId(_customServices[index].sId),
            icon: BitmapDescriptor.fromBytes(bytes),
            position: LatLng(_customServices[index].latitude?.toDouble() ?? 0.0,
                _customServices[index].longitude?.toDouble() ?? 0.0),
            infoWindow: InfoWindow(
                onTap: () => _functions[index](),
                title: _customServices[index].name,
                snippet:
                    "${_customServices[index].distance?.toStringAsFixed(1) ?? 1} km")));
        _setState();
      }
    } catch (e) {}
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  void _animateMapPosition(double minZoom) async {
    if (minZoom < 5) {
      minZoom = 14;
    } else if (minZoom < 10) {
      minZoom = 12;
    } else if (minZoom < 20) {
      minZoom = 11;
    } else if (minZoom < 35) {
      minZoom = 10.5;
    } else if (minZoom < 55) {
      minZoom = 9.2;
    } else {
      minZoom = 9;
    }
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      if (_mapController != null && mounted) {
        _mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(double.parse(_user.latitude),
                    double.parse(_user.longitude)),
                zoom: minZoom,
                bearing: 10)));
      }
    });
  }

  _openProfile(Services service) {
    if (service != null &&
        service.userType != null &&
        service.professionalId != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DoctorInfo(service.professionalId,
                  isDoc: (service.userType.toLowerCase() ==
                      Constants.doctor.toString().toLowerCase()))));
    }
  }

  _showHospitalDoctorPopup(Services service, CatalogueData catalogueData,
      Function openProfile, int index) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
            child: SingleChildScrollView(
              child: CommonWidgets().getBookProfessionalPopupForHospitalDoc(
                  service,
                  openProfile,
                  index,
                  () => _bookAppointmentWithHosDoctor(service, index),
                  context,
                  () => _openInsuranceScreen(service)),
            ),
          );
        });
  }

  _showProfessionalPopup(
      Services service, CatalogueData catalogueData, Function openProfile) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 3),
            child: SingleChildScrollView(
              child: CommonWidgets().getBookProfessionalPopup(
                  service,
                  openProfile,
                  () => _bookFacilityAppointment(service),
                  context,
                  () => _openInsuranceScreen(service)),
            ),
          );
        });
  }

  Widget _getHospitalDoctorListWidget(Services service) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          child: CommonWidgets().getBookProfessionalWidgetForHospitalDocs(
              service,
              () => _openProfile(service),
              index,
              () => _bookAppointmentWithHosDoctor(service, index),
              () => _openInsuranceScreen(service)),
        );
      },
      itemCount: service?.doctors?.length ?? 0,
    );
  }

  _bookFacilityAppointment(Services service) {
    if (!_canGoAhead()) {
      _showSnackBar(PlunesStrings.cantBookPriceExpired, shouldPop: true);
      return;
    }
    _solution = _searchedDocResults.solution;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingMainScreen(
                  price: service.newPrice?.first?.toString(),
                  profId: service.professionalId,
                  searchedSolutionServiceId: service.sId,
                  timeSlots: service.timeSlots,
                  docHosSolution: _solution,
                  bookInPrice: service.bookIn,
                  serviceName: widget.catalogueData.service ??
                      _searchedDocResults?.catalogueData?.service ??
                      PlunesStrings.NA,
                  serviceIndex: 0,
                  service: service,
                ))).then((value) {
      if (value != null &&
          value.runtimeType == "pop".runtimeType &&
          value.toString() == "pop") {
        Navigator.pop(context);
      }
    });
  }

  _bookAppointmentWithHosDoctor(Services service, int docIndex) {
    if (!_canGoAhead()) {
      _showSnackBar(PlunesStrings.cantBookPriceExpired, shouldPop: true);
      return;
    }
    _solution = _searchedDocResults.solution;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BookingMainScreen(
                  price: service.doctors[docIndex]?.newPrice?.first?.toString(),
                  profId: service.professionalId,
                  docId: service.doctors[docIndex].professionalId,
                  searchedSolutionServiceId: service.sId,
                  timeSlots: service.doctors[docIndex].timeSlots,
                  docHosSolution: _solution,
                  bookInPrice: service.doctors[docIndex].bookIn,
                  serviceName: widget.catalogueData.service ??
                      _searchedDocResults?.catalogueData?.service ??
                      PlunesStrings.NA,
                  serviceIndex: 0,
                  service: Services(
                      price: service.doctors[docIndex].price,
                      zestMoney: service.doctors[docIndex].zestMoney,
                      newPrice: service.doctors[docIndex].newPrice,
                      paymentOptions: service.paymentOptions),
                ))).then((value) {
      if (value != null &&
          value.runtimeType == "pop".runtimeType &&
          value.toString() == "pop") {
        Navigator.pop(context);
      }
    });
  }

  bool _canGoAhead() {
    bool _canGoAhead = true;
    return _canGoAhead;
    var duration = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(
            _searchedDocResults?.solution?.expirationTimer ?? 0));
    if (duration.inHours >= 1) {
      _canGoAhead = false;
    }
    return _canGoAhead;
  }

  void _showSnackBar(String message, {bool shouldPop = false}) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets()
              .getInformativePopup(globalKey: scaffoldKey, message: message);
        }).then((value) {
      if (shouldPop) {
        Navigator.pop(context);
      }
    });
  }

  Widget _getDialerWidget() {
    return Container(
      margin: EdgeInsets.only(
          left: AppConfig.horizontalBlockSize * 4,
          right: AppConfig.horizontalBlockSize * 4,
          top: AppConfig.verticalBlockSize * 2),
      child: Row(
        children: <Widget>[
          Container(
            width: AppConfig.horizontalBlockSize * 40,
            height: AppConfig.verticalBlockSize * 12.5,
            child: SfRadialGauge(axes: <RadialAxis>[
              RadialAxis(
                  pointers: [
                    RangePointer(
                        value: _gainedDiscountPercentage,
                        width: 0.3,
                        sizeUnit: GaugeSizeUnit.factor,
                        cornerStyle: CornerStyle.bothFlat,
                        gradient: SweepGradient(colors: <Color>[
                          PlunesColors.GREENCOLOR,
                          PlunesColors.GREENCOLOR
                        ], stops: <double>[
                          0.25,
                          0.75
                        ])),
                  ],
                  minimum: 0,
                  maximum: 100,
                  showLabels: false,
                  showTicks: false,
                  startAngle: 270,
                  endAngle: 270,
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        positionFactor: 0.1,
                        angle: 90,
                        widget: Text(
                          "$_gainedDiscountPercentage%",
                          style: TextStyle(
                              fontSize: 16,
                              color: PlunesColors.BLACKCOLOR,
                              fontWeight: FontWeight.w600),
                        ))
                  ])
            ]),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Real Time Saving",
                  style: TextStyle(
                      color: PlunesColors.BLACKCOLOR,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 0.5),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "$_gainedDiscountPercentage%",
                        style: TextStyle(
                            color: PlunesColors.GREENCOLOR,
                            fontWeight: FontWeight.w600,
                            fontSize: 22),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            "on original price",
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR,
                                fontWeight: FontWeight.normal,
                                fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _openInsuranceScreen(Services service) {
    if (service != null &&
        service.professionalId != null &&
        service.professionalId.trim().isNotEmpty) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ShowInsuranceListScreen(profId: service.professionalId)));
    }
  }
}