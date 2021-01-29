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
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';
import 'package:readmore/readmore.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

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

  @override
  void initState() {
    _user = UserManager().getUserDetails();
    _mapWidgets = [];
    _markers = {};
    _iconGen = IconGenerator();
    _searchSolutionBloc = SearchSolutionBloc();
    _getFacilities();
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

  @override
  void dispose() {
    _globalKeys = [];
    _functions = [];
    _customServices = [];
    _searchSolutionBloc?.dispose();
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

  Widget _getBody() {
    return Stack(
      children: [
        Container(
          child: ListView(children: _mapWidgets ?? []),
        ),
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
              _searchedDocResults.solution.services[index]);
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
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 2.8),
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
                  margin:
                      EdgeInsets.only(top: AppConfig.verticalBlockSize * 2.5),
                  child: ReadMoreText(
                    "A Botox treatment is a minimally invasive, safe, effective treatment for fine lines and wrinkles around the eyes. It can also be used on the forehead between the eyes. Botox is priced per unit.",
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
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "2-5 minutes",
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
                            color: Color(
                                CommonMethods.getColorHexFromStr("#515151")),
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                            color: Color(
                                CommonMethods.getColorHexFromStr("#515151")),
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _calculateMapData() {
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
                child: Column(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                            color: Colors.transparent, shape: BoxShape.circle),
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
              child: Column(
                children: [
                  ClipOval(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                          color: Colors.transparent, shape: BoxShape.circle),
                      child: CustomWidgets().getImageFromUrl(
                          _searchedDocResults.solution.services[index].imageUrl,
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
              builder: (context) => DoctorInfo(
                    service.professionalId,
                    isDoc: (service.userType.toLowerCase() ==
                        Constants.doctor.toString().toLowerCase()),
                  )));
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
              child: CommonWidgets().getSolutionViewWidgetForHospitalDocPopup(
                  service, catalogueData, openProfile, index, context),
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
              child: CommonWidgets().getSolutionViewWidgetPopUp(
                  service, catalogueData, openProfile, context),
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
              service, () => _openProfile(service), index),
        );
      },
      itemCount: service?.doctors?.length ?? 0,
    );
  }
}
