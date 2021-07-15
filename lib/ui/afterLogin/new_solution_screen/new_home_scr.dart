import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/Utils/youtube_player.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
import 'package:plunes/blocs/new_solution_blocs/sol_home_screen_bloc.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/new_solution_model/card_by_id_image_scr.dart';
import 'package:plunes/models/new_solution_model/know_procedure_model.dart';
import 'package:plunes/models/new_solution_model/media_content_model.dart';
import 'package:plunes/models/new_solution_model/new_speciality_model.dart';
import 'package:plunes/models/new_solution_model/solution_home_scr_model.dart';
import 'package:plunes/models/new_solution_model/top_facility_model.dart';
import 'package:plunes/models/new_solution_model/top_search_model.dart';
import 'package:plunes/models/new_solution_model/why_us_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/ui/afterLogin/EditProfileScreen.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/know_your_procedure_cards.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/show_insurance_list_screen.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/view_procedure_and_professional_screen.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_main_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/consultations.dart';
import 'package:plunes/ui/afterLogin/solution_screens/testNproceduresMainScreen.dart';
import 'package:readmore/readmore.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class NewSolutionHomePage extends BaseActivity {
  final Function func;

  NewSolutionHomePage(this.func);

  @override
  _NewSolutionHomePageState createState() => _NewSolutionHomePageState();
}

class _NewSolutionHomePageState extends BaseState<NewSolutionHomePage> {
  HomeScreenMainBloc _homeScreenMainBloc;
  SolutionHomeScreenModel _solutionHomeScreenModel;
  WhyUsModel _whyUsModel;
  KnowYourProcedureModel _knowYourProcedureModel;
  NewSpecialityModel _newSpecialityModel;
  MediaContentPlunes _mediaContentPlunes;
  TopSearchOuterModel _topSearchOuterModel;
  TopFacilityModel _topFacilityModel;
  String _failedMessage;
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  CartMainBloc _cartBloc;
  String _failedMessageForWhyUsSection;
  String _failedMessageForKnowYourProcedureSection;
  bool _isProcedureListOpened, _isTopFacilityExpanded;
  String _failedMessageForCommonSpeciality;
  String _mediaFailedMessage;
  String _failedMessageTopSearch;
  String _failedMessageTopFacility, _specialityApiFailureCause;
  List<DropdownMenuItem<String>> _specialityDropDownItems = [];
  List<SpecialityModel> _specialityItems = [];
  List<DropdownMenuItem<String>> facilityTypeWidget = [
    DropdownMenuItem(
      child: Text("Hospital"),
      value: Constants.hospital.toString(),
    ),
    DropdownMenuItem(
      child: Text("Doctor"),
      value: Constants.doctor.toString(),
    ),
    DropdownMenuItem(
      child: Text("Lab"),
      value: Constants.labDiagnosticCenter.toString(),
    ),
    DropdownMenuItem(
      child: Text("All"),
      value: _allKey,
    ),
  ];
  List<SpecialityModel> _facilityTypeList = [
    SpecialityModel(speciality: "Hospital", id: Constants.hospital.toString()),
    SpecialityModel(speciality: "Doctor", id: Constants.doctor.toString()),
    SpecialityModel(
        speciality: "Lab", id: Constants.labDiagnosticCenter.toString()),
    SpecialityModel(speciality: "All", id: _allKey),
  ];

  static final String _nearMeKey = "Near me";
  static final String _allKey = "All";

  String _userTypeFilter;
  String _locationFilter = _nearMeKey;
  String _selectedSpeciality;
  StreamController _streamControllerForTopFacility;

  List<DropdownMenuItem<String>> _facilityLocationDropDownItems = [
    DropdownMenuItem(
      child: Text(
        "Near me",
      ),
      value: _nearMeKey,
    ),
    DropdownMenuItem(
      child: Text("All"),
      value: _allKey,
    )
  ];
  List<SpecialityModel> _selectedLocationList = [
    SpecialityModel(speciality: "Near me", id: _nearMeKey),
    SpecialityModel(speciality: "All", id: _allKey)
  ];

  bool _hasSearchBar;
  String _selectedSpecialityName;
  String _userTypeFilterName;
  String _locationFilterName;
  bool _hasCalledTopFacilityApi;

  ScrollController _gridViewScrollController, _specialityScrollController;

  @override
  void initState() {
    _streamControllerForTopFacility = StreamController.broadcast();
    _gridViewScrollController = ScrollController();
    _specialityScrollController = ScrollController();
    _hasSearchBar = false;
    _cartBloc = CartMainBloc();
    _isProcedureListOpened = false;
    _isTopFacilityExpanded = false;
    _homeScreenMainBloc = HomeScreenMainBloc();
    _getCategoryData();
    _getUserDetails();
    EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
      if (event != null &&
          event.screenName == EditProfileScreen.tag &&
          mounted) {
        _getUserDetails();
        _setState();
      }
    });
    super.initState();
  }

  _getUserDetails() async {
    var user = UserManager().getUserDetails();
    if (user?.latitude != null &&
        user?.longitude != null &&
        user.latitude.isNotEmpty &&
        user.longitude.isNotEmpty &&
        user.latitude != "0.0" &&
        user.latitude != "0" &&
        user.longitude != "0.0" &&
        user.longitude != "0") {
      _checkUserLocation(user?.latitude, user?.longitude);
    }
  }

  _checkUserLocation(var latitude, var longitude,
      {String address, String region}) async {
    UserBloc()
        .isUserInServiceLocation(latitude, longitude,
            address: address, region: region)
        .then((result) {
      _setState();
    });
  }

  void _getCartCount() {
    _cartBloc.getCartCount();
  }

  @override
  void dispose() {
    _getCartCount();
    _homeScreenMainBloc?.dispose();
    _cartBloc?.dispose();
    _specialityScrollController?.dispose();
    _gridViewScrollController?.dispose();
    _streamControllerForTopFacility?.close();
    super.dispose();
  }

  _getCategoryData() {
    _homeScreenMainBloc.getSolutionHomePageCategoryData();
  }

  _onConsultationButtonClick() {
    return Navigator.push(context,
            MaterialPageRoute(builder: (context) => ConsultationScreen()))
        .then((value) {
      _getCartCount();
    });
  }

  _onTestAndProcedureButtonClick(String title, bool isProcedure) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestAndProcedureScreen(
                  screenTitle: title,
                  isProcedure: isProcedure,
                ))).then((value) {
      _getCartCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              Container(
                child: StreamBuilder<Object>(
                    stream: _homeScreenMainBloc.getHomeScreenDetailStream,
                    builder: (context, snapshot) {
                      return HomePageAppBar(
                        widget.func,
                        () {},
                        () {},
                        one: _one,
                        two: _two,
                        hasSearchBar: false,
                        searchBarText: _solutionHomeScreenModel?.searchBarText,
                        refreshCartItems: () => _getCartCount(),
                      );
                    }),
              ),
              Expanded(
                child: StreamBuilder<RequestState>(
                    stream: _homeScreenMainBloc.getHomeScreenDetailStream,
                    initialData: (_solutionHomeScreenModel == null)
                        ? RequestInProgress()
                        : null,
                    builder: (context, snapshot) {
                      if (snapshot.data is RequestSuccess) {
                        RequestSuccess successObject = snapshot.data;
                        _solutionHomeScreenModel = successObject.response;
                        _getOtherData();
                        _homeScreenMainBloc
                            ?.addIntoSolutionHomePageCategoryData(null);
                      } else if (snapshot.data is RequestFailed) {
                        RequestFailed _failedObj = snapshot.data;
                        _failedMessage = _failedObj?.failureCause;
                        _homeScreenMainBloc
                            ?.addIntoSolutionHomePageCategoryData(null);
                      } else if (snapshot.data is RequestInProgress) {
                        return CustomWidgets().getProgressIndicator();
                      }
                      return (_solutionHomeScreenModel == null ||
                              (_solutionHomeScreenModel.success != null &&
                                  !_solutionHomeScreenModel.success))
                          ? CustomWidgets().errorWidget(_failedMessage,
                              onTap: () => _getCategoryData(), isSizeLess: true)
                          : _getBody();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTextAfterFirstWord(String text) {
    if (text == null || text.isEmpty || text.split(" ").length == 0) {
      return "Your Medical Treatment";
    } else {
      List<String> texts = text.split(" ");
      String newText;
      texts.forEach((element) {
        if (newText == null) {
          newText = '';
        } else {
          newText = newText + " $element";
        }
      });
      return newText;
    }
  }

  Widget _getTopFacilitiesWidget() {
    return Container(
      margin: EdgeInsets.only(
          bottom: AppConfig.verticalBlockSize * 1.4,
          left: AppConfig.horizontalBlockSize * 2.8,
          right: AppConfig.horizontalBlockSize * 2.8),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 2.2),
            child: _sectionHeading(
                _solutionHomeScreenModel?.topFacilities ?? 'Top facilities'),
          ),
          StatefulBuilder(builder: (context, newState) {
            return FutureBuilder<RequestState>(
                future: _getSpecialityList(),
                builder: (context, snapShot) {
                  if (snapShot.data is RequestInProgress) {
                    return Container(
                      child: CustomWidgets().getProgressIndicator(),
                      height: AppConfig.verticalBlockSize * 25,
                    );
                  } else if (snapShot.data is RequestFailed) {
                    RequestFailed _failedObj = snapShot.data;
                    _specialityApiFailureCause = _failedObj?.response;
                  } else if (snapShot.data is RequestSuccess) {
                    if (_hasCalledTopFacilityApi == null)
                      _getTopFacilities(isInitialRequest: true);
                    _hasCalledTopFacilityApi = true;
                  }
                  return CommonMethods.catalogueLists == null ||
                          CommonMethods.catalogueLists.isEmpty
                      ? Container(
                          height: AppConfig.verticalBlockSize * 38,
                          child: CustomWidgets().errorWidget(
                              _specialityApiFailureCause ??
                                  "Unable to load data", onTap: () {
                            newState(() {});
                          }, isSizeLess: true),
                        )
                      : _getTopFacilityStreamBuilderWidget();
                },
                initialData: (CommonMethods.catalogueLists == null ||
                        CommonMethods.catalogueLists.isEmpty)
                    ? RequestInProgress()
                    : null);
          }),
        ],
      ),
    );
  }

  Widget _hideAbleSearchBar() {
    return Container(
      color: Color(CommonMethods.getColorHexFromStr("#FAF9F9")),
      child: Card(
        elevation: 1.8,
        margin: EdgeInsets.only(
            left: AppConfig.horizontalBlockSize * 5,
            bottom: AppConfig.verticalBlockSize * 1.5,
            right: AppConfig.horizontalBlockSize * 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          margin: EdgeInsets.only(
              left: AppConfig.horizontalBlockSize * 2,
              right: AppConfig.horizontalBlockSize * 2),
          height: AppConfig.verticalBlockSize * 6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SolutionBiddingScreen()))
                  .then((value) {
                _getCartCount();
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 4),
                  child: Icon(
                    Icons.search,
                    size: 30,
                    color: Color(CommonMethods.getColorHexFromStr("#555555")),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 2),
                    child: IgnorePointer(
                      ignoring: true,
                      child: TextField(
                        textAlign: TextAlign.left,
                        onTap: () {},
                        decoration: InputDecoration(
                          hintMaxLines: 1,
                          hintText: _solutionHomeScreenModel?.searchBarText ??
                              'Search Disease ,Test or Medical Procedure',
                          hintStyle: TextStyle(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#B1B1B1")),
                            fontSize: 16,
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBody() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            color: Color(CommonMethods.getColorHexFromStr("#FAF9F9")),
            child: Column(
              children: [
                Stack(
                  children: [
                    // background image container
                    Container(
                        height: AppConfig.verticalBlockSize * 34,
                        width: AppConfig.horizontalBlockSize * 100,
                        child: _imageFittedBox(
                            _solutionHomeScreenModel?.backgroundImage ?? "",
                            boxFit: BoxFit.cover)),
                    Container(
                      margin:
                          EdgeInsets.only(top: AppConfig.verticalBlockSize * 8),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                                left: AppConfig.verticalBlockSize * 4,
                                right: AppConfig.verticalBlockSize * 4),
                            child: RichText(
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: _getHeading(),
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23))
                                ])),
                          ),
                          // search box container
                          VisibilityDetector(
                            key: Key("VisibilityDetector"),
                            onVisibilityChanged: (visibilityInfo) {
                              if (visibilityInfo != null) {
                                var visiblePercentage =
                                    visibilityInfo.visibleFraction * 100;
                                if (visiblePercentage < 1) {
                                  _hasSearchBar = true;
                                } else {
                                  _hasSearchBar = false;
                                }
                                _setState();
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: AppConfig.verticalBlockSize * 2,
                                  left: AppConfig.verticalBlockSize * 2,
                                  right: AppConfig.verticalBlockSize * 2),
                              height: AppConfig.verticalBlockSize * 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SolutionBiddingScreen()))
                                      .then((value) {
                                    _getCartCount();
                                  });
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              AppConfig.horizontalBlockSize *
                                                  4),
                                      child: Icon(
                                        Icons.search,
                                        size: 30,
                                        color: Color(
                                            CommonMethods.getColorHexFromStr(
                                                "#555555")),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.only(bottom: 2),
                                        child: IgnorePointer(
                                          ignoring: true,
                                          child: TextField(
                                            textAlign: TextAlign.left,
                                            onTap: () {},
                                            decoration: InputDecoration(
                                              hintMaxLines: 1,
                                              hintText: _solutionHomeScreenModel
                                                      ?.searchBarText ??
                                                  'Search Disease ,Test or Medical Procedure',
                                              hintStyle: TextStyle(
                                                color: Color(CommonMethods
                                                    .getColorHexFromStr(
                                                        "#B1B1B1")),
                                                fontSize: 16,
                                              ),
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          StreamBuilder<Object>(
                              stream:
                                  _homeScreenMainBloc?.commonSpecialityStream,
                              builder: (context, snapshot) {
                                return (_newSpecialityModel == null ||
                                        _newSpecialityModel.data == null ||
                                        _newSpecialityModel.data.isEmpty)
                                    ? Container()
                                    : Container(
                                        height:
                                            AppConfig.verticalBlockSize * 4.5,
                                        margin: EdgeInsets.only(
                                          top: AppConfig.verticalBlockSize * 2,
                                          left: AppConfig.verticalBlockSize * 2,
                                          right:
                                              AppConfig.verticalBlockSize * 2,
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                var specialityData =
                                                    _newSpecialityModel
                                                        .data[index];
                                                ProcedureData procedureData =
                                                    ProcedureData(
                                                        sId: specialityData
                                                            ?.specialityId,
                                                        defination:
                                                            specialityData
                                                                ?.definition,
                                                        speciality:
                                                            specialityData
                                                                ?.speciality,
                                                        familyImage: specialityData
                                                            ?.specailizationImage,
                                                        specialityId:
                                                            specialityData
                                                                ?.specialityId,
                                                        details: specialityData
                                                            ?.definition,
                                                        familyName:
                                                            specialityData
                                                                ?.speciality);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewProcedureAndProfessional(
                                                                shouldUseSpecializationApi:
                                                                    true,
                                                                procedureData:
                                                                    procedureData))).then(
                                                    (value) {
                                                  _getCartCount();
                                                });
                                              },
                                              onDoubleTap: () {},
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                margin:
                                                    EdgeInsets.only(right: 5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    color: Color(CommonMethods
                                                        .getColorHexFromStr(
                                                            "#FAFBFD"))),
                                                child: Text(
                                                  _newSpecialityModel
                                                          .data[index]
                                                          .speciality ??
                                                      "",
                                                  style: TextStyle(
                                                      color: Color(CommonMethods
                                                          .getColorHexFromStr(
                                                              "#303030")),
                                                      fontSize: 14),
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount: _newSpecialityModel
                                                  .data?.length ??
                                              0,
                                        ),
                                      );
                              })
                        ],
                      ),
                    )
                  ],
                ),
                // services box row
                _servicesRow(),
                _getProcedureWidget(),
                // heading - why us
                _getWhyUsSection(),
                _getSpecialityWidget(),

                // vertical view of cards
                _getTopFacilitiesWidget(),

                _getTopSearchWidget(),

                _getVideoWidget(),

                // section heading - reviews
                // Container(
                //   margin: EdgeInsets.only(
                //       top: AppConfig.verticalBlockSize * 5,
                //       left: AppConfig.horizontalBlockSize * 2,
                //       right: AppConfig.horizontalBlockSize * 60),
                //   child: _sectionHeading('Reviews'),
                // ),

                // review card
              ],
            ),
          ),
        ),
        Positioned(
          child: Container(
            alignment: Alignment.center,
            child: IgnorePointer(
                child: (_hasSearchBar) ? _hideAbleSearchBar() : Container(),
                ignoring: !_hasSearchBar),
          ),
          top: 0.0,
          right: 0.0,
          left: 0.0,
        )
      ],
    );
  }

  Widget _servicesRow() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: AppConfig.horizontalBlockSize * 4.8,
          horizontal: AppConfig.horizontalBlockSize * 2.8,
        ),
        child: Row(
          children: _solutionHomeScreenModel?.data
                  ?.map((e) =>
                      _servicesButtonCard(e.categoryImage, e.categoryName, e))
                  ?.toList() ??
              [],
        ),
      ),
    );
  }

  Widget _servicesButtonCard(String url, String label, HomeScreenButtonInfo e) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (e.category != null &&
              e.category.isNotEmpty &&
              e.category == Constants.consultationKey) {
            _onConsultationButtonClick();
          } else if (e.category != null &&
              e.category.isNotEmpty &&
              (e.category == Constants.procedureKey ||
                  e.category == Constants.testKey)) {
            _onTestAndProcedureButtonClick(
                e.categoryName, e.category == Constants.procedureKey);
          }
        },
        child: Column(
          children: [
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                height: 78,
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                child: SizedBox.expand(
                  child: ClipRRect(
                    child: _imageFittedBox(url, boxFit: BoxFit.contain),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  bottom: AppConfig.verticalBlockSize * 0.3, left: 2, right: 2),
              alignment: Alignment.center,
              child: Text(
                label ?? "",
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _getOtherData() {
    _getWhyUsData();
    _getKnowYourProcedureData();
    // _getTopFacilities();
    _getTopSearch();
    _getSpecialities();
    _getVideos();
    _getReviews();
  }

  void _getWhyUsData() {
    _homeScreenMainBloc.getWhyUsData();
  }

  void _getKnowYourProcedureData() {
    _homeScreenMainBloc.getKnowYourProcedureData();
  }

  void _getTopFacilities({bool isInitialRequest = false}) {
    _homeScreenMainBloc.getTopFacilities(
        specialityId: _selectedSpeciality,
        shouldSortByNearest: (_locationFilter == _allKey) ? false : true,
        facilityType: _userTypeFilter,
        isInitialRequest: isInitialRequest);
  }

  void _getTopSearch() {
    _homeScreenMainBloc.getTopSearches();
  }

  void _getSpecialities() {
    _homeScreenMainBloc.getCommonSpecialities();
  }

  void _getVideos() {
    _homeScreenMainBloc.getMediaContent();
  }

  void _getReviews() {}

  Widget _getWhyUsSection() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.4),
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 2.8),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2.2),
              child:
                  _sectionHeading(_solutionHomeScreenModel?.whyUs ?? 'Why Us'),
            ),
            // horizontal list view of cards
            Container(
              height: AppConfig.verticalBlockSize * 44,
              child: StreamBuilder<RequestState>(
                  stream: _homeScreenMainBloc.getWhyUsStream,
                  builder: (context, snapshot) {
                    if (snapshot.data is RequestSuccess) {
                      RequestSuccess successObject = snapshot.data;
                      _whyUsModel = successObject.response;
                      _homeScreenMainBloc?.addIntoGetWhyUsDataStream(null);
                    } else if (snapshot.data is RequestFailed) {
                      RequestFailed _failedObj = snapshot.data;
                      _failedMessageForWhyUsSection = _failedObj?.failureCause;
                      _homeScreenMainBloc?.addIntoGetWhyUsDataStream(null);
                    } else if (snapshot.data is RequestInProgress) {
                      return CustomWidgets().getProgressIndicator();
                    }
                    return (_whyUsModel == null ||
                            (_whyUsModel.success != null &&
                                !_whyUsModel.success) ||
                            _whyUsModel.data == null ||
                            _whyUsModel.data.isEmpty)
                        ? CustomWidgets().errorWidget(
                            _failedMessageForWhyUsSection,
                            onTap: () => _getWhyUsData(),
                            isSizeLess: true)
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return _getWhyUsCard(
                                  _whyUsModel.data[index].titleImage,
                                  _whyUsModel.data[index].title ?? "",
                                  _whyUsModel.data[index].sId);
                            },
                            itemCount: _whyUsModel?.data?.length ?? 0,
                          );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getWhyUsCard(String imageUrl, String heading, String id) {
    return Container(
      width: AppConfig.horizontalBlockSize * 62,
      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
      child: InkWell(
        onTap: () {
          if (id != null && id.isNotEmpty) {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WhyUsCardsByIdScreen(id)))
                .then((value) {
              _getCartCount();
            });
          }
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Container(
                height: AppConfig.verticalBlockSize * 33,
                width: double.infinity,
                child: ClipRRect(
                  child: _imageFittedBox(imageUrl, boxFit: BoxFit.fitWidth),
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                )),
            Flexible(
              child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(
                    top: AppConfig.verticalBlockSize * 2,
                    left: AppConfig.horizontalBlockSize * 1,
                    right: AppConfig.horizontalBlockSize * 1),
                child: IgnorePointer(
                  ignoring: true,
                  child: ReadMoreText(heading ?? "",
                      textAlign: TextAlign.left,
                      trimLines: 2,
                      trimCollapsedText: " ..Learn more",
                      trimMode: TrimMode.Line,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff444444),
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getProcedureWidget() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 1.4),
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: AppConfig.horizontalBlockSize * 2.8),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2.2),
              child: _sectionHeading(
                  _solutionHomeScreenModel?.knowYourProcedure ??
                      'Know your procedure'),
            ),
            StreamBuilder<RequestState>(
                stream: _homeScreenMainBloc.knowYourProcedureStream,
                initialData: _knowYourProcedureModel == null
                    ? RequestInProgress()
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.data is RequestSuccess) {
                    RequestSuccess successObject = snapshot.data;
                    _knowYourProcedureModel = successObject.response;
                    _homeScreenMainBloc
                        ?.addIntoKnowYourProcedureDataStream(null);
                  } else if (snapshot.data is RequestFailed) {
                    RequestFailed _failedObj = snapshot.data;
                    _failedMessageForKnowYourProcedureSection =
                        _failedObj?.failureCause;
                    _homeScreenMainBloc
                        ?.addIntoKnowYourProcedureDataStream(null);
                  } else if (snapshot.data is RequestInProgress) {
                    return Container(
                      child: CustomWidgets().getProgressIndicator(),
                      height: AppConfig.verticalBlockSize * 35,
                      color: PlunesColors.WHITECOLOR,
                    );
                  }
                  return (_knowYourProcedureModel == null ||
                          _knowYourProcedureModel.data == null ||
                          _knowYourProcedureModel.data.isEmpty)
                      ? Container(
                          height: AppConfig.verticalBlockSize * 40,
                          color: PlunesColors.WHITECOLOR,
                          child: CustomWidgets().errorWidget(
                              _knowYourProcedureModel?.message ??
                                  _failedMessageForKnowYourProcedureSection,
                              onTap: () => _getKnowYourProcedureData(),
                              isSizeLess: true),
                        )
                      : _proceduresGrid();
                  // Column(
                  //         mainAxisAlignment: MainAxisAlignment.start,
                  //         children: [
                  //           _proceduresGrid(),
                  //           _getViewMoreButtonForProcedure()
                  //         ],
                  //       );
                }),
          ],
        ),
      ),
    );
  }

  Widget _proceduresGrid() {
    return Center(
      child: Container(
        height: AppConfig.verticalBlockSize * 56,
        margin: EdgeInsets.only(bottom: 5),
        child: GridView.count(
            shrinkWrap: true,
            controller: _gridViewScrollController,
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 14,
            padding: EdgeInsets.only(bottom: 15),
            childAspectRatio: 1.2,
            scrollDirection: Axis.horizontal,
            // physics: NeverScrollableScrollPhysics(),
            children: _getProcedureAlteredList()),
      ),
    );
  }

  Widget _getViewMoreButtonForProcedure() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: InkWell(
        onDoubleTap: () {},
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KnowYourProcedureCard(
                          _knowYourProcedureModel,
                          _solutionHomeScreenModel?.knowYourProcedure)))
              .then((value) {
            _getCartCount();
          });
          // _isProcedureListOpened = !_isProcedureListOpened;
          // _homeScreenMainBloc?.addIntoKnowYourProcedureDataStream(null);
        },
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: AppConfig.horizontalBlockSize * 2,
              vertical: AppConfig.verticalBlockSize * 2.2),
          child: Text(
            _isProcedureListOpened ? "View less" : "View more",
            style: TextStyle(color: PlunesColors.GREENCOLOR, fontSize: 13),
          ),
        ),
      ),
    );
  }

  List<Widget> _getProcedureAlteredList() {
    List<Widget> list = [];
    // if (_isProcedureListOpened) {
    int length = _knowYourProcedureModel.data.length;
    for (int index = 0; index < length; index++) {
      var data = _knowYourProcedureModel.data[index];
      list.add(_proceduresCard(data.familyImage ?? "", data.familyName ?? "",
          data.details ?? "", data));
    }
    // }
    // else {
    //   int length = (_knowYourProcedureModel.data.length > 6)
    //       ? 6
    //       : _knowYourProcedureModel.data.length;
    //   for (int index = 0; index < length; index++) {
    //     var data = _knowYourProcedureModel.data[index];
    //     list.add(_proceduresCard(data.familyImage ?? "", data.familyName ?? "",
    //         data.details ?? "", data));
    //   }
    // }
    return list;
  }

  Widget _proceduresCard(
      String url, String label, String text, ProcedureData procedureData) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProcedureAndProfessional(
                    procedureData: procedureData))).then((value) {
          _getCartCount();
        });
      },
      onDoubleTap: () {},
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                child: Container(
                  child: _imageFittedBox(url),
                  height: AppConfig.verticalBlockSize * 15,
                  width: double.infinity,
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 2,
                      right: AppConfig.horizontalBlockSize * 2,
                      top: AppConfig.verticalBlockSize * 0.1),
                  child: Text(
                    label ?? "",
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    style:
                        TextStyle(fontSize: 15, color: PlunesColors.BLACKCOLOR),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 2,
                      top: AppConfig.verticalBlockSize * 0.2,
                      right: AppConfig.horizontalBlockSize * 2),
                  child: IgnorePointer(
                    ignoring: true,
                    child: ReadMoreText(text ?? "",
                        textAlign: TextAlign.left,
                        trimLines: 2,
                        trimCollapsedText: " ..Read More",
                        colorClickableText: Color(0xff107C6F),
                        trimMode: TrimMode.Line,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff444444),
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSpecialityWidget() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.4),
      child: Container(
        margin: EdgeInsets.only(
            right: AppConfig.horizontalBlockSize * 2.8,
            left: AppConfig.horizontalBlockSize * 2.8,
            bottom: AppConfig.verticalBlockSize * 2.2),
        child: Column(
          children: [
            // heading - speciality
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2.2),
              child: _sectionHeading(
                  _solutionHomeScreenModel?.speciality ?? 'Speciality'),
            ),

            // horizontal list view of specialities
            StreamBuilder<RequestState>(
                stream: _homeScreenMainBloc.commonSpecialityStream,
                initialData:
                    _newSpecialityModel == null ? RequestInProgress() : null,
                builder: (context, snapshot) {
                  if (snapshot.data is RequestSuccess) {
                    RequestSuccess successObject = snapshot.data;
                    _newSpecialityModel = successObject.response;
                    _homeScreenMainBloc
                        ?.addIntoGetCommonSpecialitiesDataStream(null);
                  } else if (snapshot.data is RequestFailed) {
                    RequestFailed _failedObj = snapshot.data;
                    _failedMessageForCommonSpeciality =
                        _failedObj?.failureCause;
                    _homeScreenMainBloc
                        ?.addIntoGetCommonSpecialitiesDataStream(null);
                  } else if (snapshot.data is RequestInProgress) {
                    return Container(
                      child: CustomWidgets().getProgressIndicator(),
                      height: AppConfig.verticalBlockSize * 28,
                    );
                  }
                  return (_newSpecialityModel == null ||
                          _newSpecialityModel.data == null ||
                          _newSpecialityModel.data.isEmpty)
                      ? Container(
                          child: CustomWidgets().errorWidget(
                              _newSpecialityModel?.message ??
                                  _failedMessageForCommonSpeciality,
                              onTap: () => _getSpecialities(),
                              isSizeLess: true),
                        )
                      : Container(
                          height: AppConfig.verticalBlockSize * 40,
                          child: GridView.builder(
                            controller: _specialityScrollController,
                            padding: EdgeInsets.only(bottom: 15),
                            itemBuilder: (context, index) {
                              return _specialCard(
                                  _newSpecialityModel
                                          .data[index]?.specialityIconImage ??
                                      "",
                                  _newSpecialityModel.data[index]?.speciality,
                                  _newSpecialityModel.data[index]?.definition ??
                                      "",
                                  _newSpecialityModel.data[index]);
                            },
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.3,
                                    mainAxisSpacing: 20,
                                    crossAxisSpacing: 1),
                            itemCount: _newSpecialityModel.data.length ?? 0,
                          ),
                        );
                }),
          ],
        ),
      ),
    );
  }

  Widget _getVideoWidget() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.4),
      child: Container(
        margin: EdgeInsets.only(
            right: AppConfig.horizontalBlockSize * 2.8,
            left: AppConfig.horizontalBlockSize * 2.8,
            bottom: AppConfig.verticalBlockSize * 2.2),
        child: Column(
          children: [
            // section heading - vedio
            Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.symmetric(
                    vertical: AppConfig.verticalBlockSize * 2.2),
                child: _sectionHeading(
                    _solutionHomeScreenModel?.videos ?? 'Video')),

            // vedio card
            StreamBuilder<RequestState>(
                stream: _homeScreenMainBloc.mediaStream,
                builder: (context, snapshot) {
                  if (snapshot.data is RequestSuccess) {
                    RequestSuccess successObject = snapshot.data;
                    _mediaContentPlunes = successObject.response;
                    _homeScreenMainBloc?.addIntoMediaStream(null);
                  } else if (snapshot.data is RequestFailed) {
                    RequestFailed _failedObj = snapshot.data;
                    _mediaFailedMessage = _failedObj?.failureCause;
                    _homeScreenMainBloc?.addIntoMediaStream(null);
                  } else if (snapshot.data is RequestInProgress) {
                    return Container(
                      child: CustomWidgets().getProgressIndicator(),
                      height: AppConfig.verticalBlockSize * 28,
                    );
                  }
                  return (_mediaContentPlunes == null ||
                          _mediaContentPlunes.data == null ||
                          _mediaContentPlunes.data.isEmpty)
                      ? Container(
                          child: CustomWidgets().errorWidget(
                              _mediaFailedMessage,
                              onTap: () => _getVideos(),
                              isSizeLess: true),
                        )
                      : Container(
                          height: AppConfig.verticalBlockSize * 38,
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return _getVideoCard(
                                  "https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(_mediaContentPlunes.data[index]?.mediaUrl ?? "")}/0.jpg",
                                  _mediaContentPlunes.data[index]?.service ??
                                      _mediaContentPlunes.data[index]?.name ??
                                      "",
                                  _mediaContentPlunes.data[index].testimonial,
                                  _mediaContentPlunes.data[index]?.mediaUrl);
                            },
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            itemCount: _mediaContentPlunes?.data?.length ?? 0,
                          ),
                        );
                })
          ],
        ),
      ),
    );
  }

  Widget _getVideoCard(
      String imageUrl, String label, String text, String mediaUrl) {
    return Container(
      margin: EdgeInsets.only(right: 4),
      width: AppConfig.horizontalBlockSize * 82,
      child: InkWell(
        onTap: () {
          if (mediaUrl == null || mediaUrl.trim().isEmpty) {
            return;
          }
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => YoutubePlayerProvider(
                        mediaUrl,
                        title: label,
                      )));
        },
        onDoubleTap: () {},
        child: Card(
          elevation: 2.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    child: ClipRRect(
                      child: _imageFittedBox(imageUrl, boxFit: BoxFit.fitWidth),
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10)),
                    ),
                    height: AppConfig.verticalBlockSize * 26,
                    width: double.infinity,
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Image.asset(
                        PlunesImages.pauseVideoIcon,
                        height: 50,
                        width: 50,
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(
                    left: AppConfig.horizontalBlockSize * 2,
                    right: AppConfig.horizontalBlockSize * 2,
                    top: AppConfig.verticalBlockSize * 0.3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label ?? "",
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                      left: AppConfig.horizontalBlockSize * 2,
                      right: AppConfig.horizontalBlockSize * 2,
                      top: AppConfig.verticalBlockSize * 0.3),
                  child: Text(
                    text ?? "",
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTopSearchWidget() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      margin: EdgeInsets.only(bottom: AppConfig.verticalBlockSize * 1.4),
      child: Container(
        margin: EdgeInsets.only(
            right: AppConfig.horizontalBlockSize * 2.8,
            left: AppConfig.horizontalBlockSize * 2.8,
            bottom: AppConfig.verticalBlockSize * 2.2),
        child: Column(
          children: [
            // heading - top search
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2.2),
              child: _sectionHeading(
                  _solutionHomeScreenModel?.topSearch ?? 'Top Search'),
            ),

            // horizontal list view of top search cards
            StreamBuilder<RequestState>(
                stream: _homeScreenMainBloc.topSearchStream,
                builder: (context, snapshot) {
                  if (snapshot.data is RequestSuccess) {
                    RequestSuccess successObject = snapshot.data;
                    _topSearchOuterModel = successObject.response;
                    _homeScreenMainBloc?.addIntoTopSearchStream(null);
                  } else if (snapshot.data is RequestFailed) {
                    RequestFailed _failedObj = snapshot.data;
                    _failedMessageTopSearch = _failedObj?.failureCause;
                    _homeScreenMainBloc?.addIntoTopSearchStream(null);
                  } else if (snapshot.data is RequestInProgress) {
                    return Container(
                      child: CustomWidgets().getProgressIndicator(),
                      height: AppConfig.verticalBlockSize * 25,
                    );
                  }
                  return (_topSearchOuterModel == null ||
                          (_topSearchOuterModel.success != null &&
                              !_topSearchOuterModel.success) ||
                          _topSearchOuterModel.data == null ||
                          _topSearchOuterModel.data.isEmpty)
                      ? Container(
                          height: AppConfig.verticalBlockSize * 38,
                          child: CustomWidgets().errorWidget(
                              _failedMessageTopSearch,
                              onTap: () => _getTopSearch(),
                              isSizeLess: true),
                        )
                      : Container(
                          height: AppConfig.verticalBlockSize * 24,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return _topSearchCard(
                                  _topSearchOuterModel
                                          .data[index].specializationImage ??
                                      "",
                                  _topSearchOuterModel.data[index].service ??
                                      "",
                                  _topSearchOuterModel.data[index]);
                            },
                            itemCount: _topSearchOuterModel.data.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                          ),
                        );
                }),
          ],
        ),
      ),
    );
  }

  String _getHeading() {
    if (_solutionHomeScreenModel == null ||
        _solutionHomeScreenModel.heading == null ||
        _solutionHomeScreenModel.heading.trim().isEmpty) {
      return 'Book Your Medical Treatment';
    } else {
      return _solutionHomeScreenModel.heading;
    }
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _specialCard(
      String imageUrl, String label, String text, SpecData specialityData) {
    return Container(
      child: InkWell(
        onTap: () {
          ProcedureData procedureData = ProcedureData(
              sId: specialityData?.specialityId,
              defination: specialityData?.definition,
              speciality: specialityData?.speciality,
              familyImage: specialityData?.specailizationImage,
              specialityId: specialityData?.specialityId,
              details: specialityData?.definition,
              familyName: specialityData?.speciality);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewProcedureAndProfessional(
                      shouldUseSpecializationApi: true,
                      procedureData: procedureData))).then((value) {
            _getCartCount();
          });
        },
        onDoubleTap: () {},
        child: Column(
          children: [
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                width: 102,
                height: AppConfig.verticalBlockSize * 12,
                padding: EdgeInsets.all(15),
                child: ClipRRect(
                  child: _imageFittedBox(imageUrl, boxFit: BoxFit.fill),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
              ),
            ),
            Flexible(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 2, vertical: 3),
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text(
                    label ?? "",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _topSearchCard(
      String imageUrl, String text, TopSearchData specialityData) {
    return Container(
      width: AppConfig.horizontalBlockSize * 45,
      margin: EdgeInsets.only(right: 4),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: InkWell(
          onTap: () {
            ProcedureData procedureData = ProcedureData(
                sId: specialityData?.specialityId,
                duration: specialityData?.duration,
                category: specialityData?.category,
                sittings: specialityData?.sittings,
                defination: specialityData?.definition,
                speciality: specialityData?.speciality,
                familyImage: specialityData?.specializationImage,
                specialityId: specialityData?.specialityId,
                details: specialityData?.definition,
                dnd: specialityData.dnd,
                familyName: specialityData?.speciality);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewProcedureAndProfessional(
                        shouldUseSpecializationApi: true,
                        procedureData: procedureData))).then((value) {
              _getCartCount();
            });
          },
          onDoubleTap: () {},
          child: Column(
            children: [
              Container(
                height: AppConfig.verticalBlockSize * 15,
                child: ClipRRect(
                  child: _imageFittedBox(imageUrl),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
              ),
              Flexible(
                child: ListTile(
                  title: Text(
                    text ?? "",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color:
                            Color(CommonMethods.getColorHexFromStr("#444444"))),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTopFacilityStreamBuilderWidget() {
    return StreamBuilder<RequestState>(
        stream: _homeScreenMainBloc.topFacilityStream,
        initialData: (_topFacilityModel == null) ? RequestInProgress() : null,
        builder: (context, snapshot) {
          if (snapshot.data is RequestSuccess) {
            RequestSuccess successObject = snapshot.data;
            _topFacilityModel = successObject.response;
            _homeScreenMainBloc?.addIntoTopFacilityStream(null);
          } else if (snapshot.data is RequestFailed) {
            RequestFailed _failedObj = snapshot.data;
            _failedMessageTopFacility = _failedObj?.failureCause;
            _homeScreenMainBloc?.addIntoTopFacilityStream(null);
          } else if (snapshot.data is RequestInProgress) {
            return Container(
              child: CustomWidgets().getProgressIndicator(),
              height: AppConfig.verticalBlockSize * 25,
            );
          }
          return (_topFacilityModel == null ||
                  (_topFacilityModel.success != null &&
                      !_topFacilityModel.success) ||
                  _topFacilityModel.data == null ||
                  _topFacilityModel.data.isEmpty)
              ? Container(
                  height: AppConfig.verticalBlockSize * 38,
                  child: CustomWidgets().errorWidget(_failedMessageTopFacility,
                      onTap: () {
                    _selectedSpeciality = null;
                    _userTypeFilter = null;
                    _locationFilter = _nearMeKey;
                    _getTopFacilities(isInitialRequest: true);
                  }, isSizeLess: true))
              : Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container(
                      //   margin: EdgeInsets.only(
                      //       bottom: AppConfig.verticalBlockSize * 2.2),
                      //   child: SingleChildScrollView(
                      //     scrollDirection: Axis.horizontal,
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       children: [
                      //         Container(
                      //           padding: EdgeInsets.only(
                      //               top: AppConfig.verticalBlockSize * 1.2,
                      //               bottom: AppConfig.verticalBlockSize * 1.2,
                      //               left: AppConfig.horizontalBlockSize * 5,
                      //               right: AppConfig.horizontalBlockSize * 1),
                      //           margin: EdgeInsets.only(
                      //               right: AppConfig.horizontalBlockSize * 3,
                      //               left: AppConfig.horizontalBlockSize * 2.2),
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.all(
                      //                   Radius.circular(
                      //                       AppConfig.horizontalBlockSize *
                      //                           10)),
                      //               color: Color(
                      //                   CommonMethods.getColorHexFromStr(
                      //                       "#00000012")),
                      //               border: Border.all(
                      //                   width: 0.8,
                      //                   color: Color(
                      //                       CommonMethods.getColorHexFromStr(
                      //                           "#26AF78")))),
                      //           child: InkWell(
                      //             onTap: () {
                      //               _getModelBottomSheetForServiceList(context);
                      //             },
                      //             onDoubleTap: () {},
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.end,
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment.center,
                      //               children: [
                      //                 Text(
                      //                   _selectedSpecialityName ?? "Service",
                      //                   style: TextStyle(
                      //                       fontSize: 14,
                      //                       color: PlunesColors.BLACKCOLOR),
                      //                 ),
                      //                 Padding(
                      //                   padding:
                      //                       const EdgeInsets.only(left: 4.0),
                      //                   child: Icon(Icons.arrow_drop_down),
                      //                 )
                      //               ],
                      //             ),
                      //           ),
                      //           // DropdownButton<String>(
                      //           //   items: _getSpecialityDropdownItems(),
                      //           //   underline: Container(),
                      //           //   value: _selectedSpeciality,
                      //           //   isExpanded: false,
                      //           //   hint: Text(
                      //           //     "Service",
                      //           //     style: TextStyle(
                      //           //         fontSize: 14,
                      //           //         color: PlunesColors.BLACKCOLOR),
                      //           //   ),
                      //           //   onChanged: (spec) {
                      //           //     _selectedSpeciality = spec;
                      //           //     _doFilterAndGetFacilities();
                      //           //   },
                      //           // ),
                      //         ),
                      //         Container(
                      //           padding: EdgeInsets.only(
                      //               top: AppConfig.verticalBlockSize * 1.2,
                      //               bottom: AppConfig.verticalBlockSize * 1.2,
                      //               left: AppConfig.horizontalBlockSize * 5,
                      //               right: AppConfig.horizontalBlockSize * 1),
                      //           margin: EdgeInsets.only(
                      //               right: AppConfig.horizontalBlockSize * 3),
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.all(
                      //                   Radius.circular(
                      //                       AppConfig.horizontalBlockSize *
                      //                           10)),
                      //               color: Color(
                      //                   CommonMethods.getColorHexFromStr(
                      //                       "#00000012")),
                      //               border: Border.all(
                      //                   width: 0.8,
                      //                   color: Color(
                      //                       CommonMethods.getColorHexFromStr(
                      //                           "#26AF78")))),
                      //           child: InkWell(
                      //               onTap: () {
                      //                 _getModelBottomSheetForFacilityType(
                      //                     context);
                      //               },
                      //               onDoubleTap: () {},
                      //               child: Row(
                      //                 mainAxisAlignment: MainAxisAlignment.end,
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.center,
                      //                 children: [
                      //                   Text(
                      //                     _userTypeFilterName ?? "Facility",
                      //                     style: TextStyle(
                      //                         fontSize: 14,
                      //                         color: PlunesColors.BLACKCOLOR),
                      //                   ),
                      //                   Padding(
                      //                     padding:
                      //                         const EdgeInsets.only(left: 4.0),
                      //                     child: Icon(Icons.arrow_drop_down),
                      //                   )
                      //                 ],
                      //               )),
                      //           // DropdownButton<String>(
                      //           //   items: facilityTypeWidget,
                      //           //   underline: Container(),
                      //           //   value: _userTypeFilter,
                      //           //   isExpanded: false,
                      //           //   hint: Text(
                      //           //     "Facility",
                      //           //     style: TextStyle(
                      //           //         fontSize: 14,
                      //           //         color: PlunesColors.BLACKCOLOR),
                      //           //   ),
                      //           //   onChanged: (userType) {
                      //           //     _userTypeFilter = userType;
                      //           //     _doFilterAndGetFacilities();
                      //           //   },
                      //           // ),
                      //         ),
                      //         (UserManager().getUserDetails().latitude != null &&
                      //                 UserManager()
                      //                     .getUserDetails()
                      //                     .latitude
                      //                     .isNotEmpty &&
                      //                 UserManager().getUserDetails().longitude !=
                      //                     null &&
                      //                 UserManager()
                      //                     .getUserDetails()
                      //                     .longitude
                      //                     .isNotEmpty &&
                      //                 UserManager()
                      //                     .getIsUserInServiceLocation())
                      //             ? Container(
                      //                 margin: EdgeInsets.only(
                      //                     right: AppConfig.horizontalBlockSize *
                      //                         3),
                      //                 padding: EdgeInsets.only(
                      //                     top:
                      //                         AppConfig.verticalBlockSize * 1.2,
                      //                     bottom:
                      //                         AppConfig.verticalBlockSize * 1.2,
                      //                     left:
                      //                         AppConfig.horizontalBlockSize * 5,
                      //                     right: AppConfig.horizontalBlockSize *
                      //                         1),
                      //                 decoration: BoxDecoration(
                      //                     borderRadius: BorderRadius.all(
                      //                         Radius.circular(AppConfig
                      //                                 .horizontalBlockSize *
                      //                             10)),
                      //                     color:
                      //                         Color(CommonMethods.getColorHexFromStr("#00000012")),
                      //                     border: Border.all(width: 0.8, color: Color(CommonMethods.getColorHexFromStr("#26AF78")))),
                      //                 child: InkWell(
                      //                     onTap: () {
                      //                       _getModelBottomSheetForLocationType(
                      //                           context);
                      //                     },
                      //                     onDoubleTap: () {},
                      //                     child: Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.end,
                      //                       crossAxisAlignment:
                      //                           CrossAxisAlignment.center,
                      //                       children: [
                      //                         Text(
                      //                           _locationFilterName ??
                      //                               "Near Me",
                      //                           style: TextStyle(
                      //                               fontSize: 14,
                      //                               color: PlunesColors
                      //                                   .BLACKCOLOR),
                      //                         ),
                      //                         Padding(
                      //                           padding: const EdgeInsets.only(
                      //                               left: 4.0),
                      //                           child:
                      //                               Icon(Icons.arrow_drop_down),
                      //                         )
                      //                       ],
                      //                     ))
                      //                 // DropdownButton(
                      //                 //   items: _facilityLocationDropDownItems,
                      //                 //   isExpanded: false,
                      //                 //   value: _locationFilter,
                      //                 //   underline: Container(),
                      //                 //   hint: Text(
                      //                 //     "Near Me",
                      //                 //     style: TextStyle(
                      //                 //         fontSize: 14,
                      //                 //         color: PlunesColors.BLACKCOLOR),
                      //                 //   ),
                      //                 //   onChanged: (locationFilter) {
                      //                 //     _locationFilter = locationFilter;
                      //                 //     _doFilterAndGetFacilities();
                      //                 //   },
                      //                 // ),
                      //                 )
                      //             : Container()
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (_topFacilityModel.data[index] != null &&
                                  _topFacilityModel.data[index].userType !=
                                      null &&
                                  _topFacilityModel
                                          .data[index].professionalId !=
                                      null) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DoctorInfo(
                                            _topFacilityModel
                                                .data[index].professionalId,
                                            isDoc: (_topFacilityModel
                                                    .data[index].userType
                                                    .toLowerCase() ==
                                                Constants.doctor
                                                    .toString()
                                                    .toLowerCase()))));
                              }
                            },
                            onDoubleTap: () {},
                            child: CommonWidgets().getHospitalCard(
                                _topFacilityModel.data[index]?.imageUrl ?? '',
                                CommonMethods.getStringInCamelCase(
                                    _topFacilityModel.data[index].name),
                                _topFacilityModel.data[index].biography ?? '',
                                _topFacilityModel.data[index]?.rating,
                                _topFacilityModel.data[index],
                                _streamControllerForTopFacility,
                                () => _openInsuranceScreen(
                                    _topFacilityModel.data[index])),
                          );
                        },
                        itemCount: ((_topFacilityModel.data.length > 6) &&
                                (!_isTopFacilityExpanded))
                            ? 5
                            : _topFacilityModel.data.length,
                      ),
                      (_topFacilityModel.data.length > 6)
                          ? Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: InkWell(
                                onDoubleTap: () {},
                                onTap: () {
                                  _isTopFacilityExpanded =
                                      !_isTopFacilityExpanded;
                                  _homeScreenMainBloc
                                      ?.addIntoTopFacilityStream(null);
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal:
                                          AppConfig.horizontalBlockSize * 2,
                                      vertical:
                                          AppConfig.verticalBlockSize * 2.2),
                                  child: Text(
                                    _isTopFacilityExpanded
                                        ? "View less"
                                        : "View more",
                                    style: TextStyle(
                                        color: PlunesColors.GREENCOLOR,
                                        fontSize: 13),
                                  ),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                );
        });
  }

  _openInsuranceScreen(TopFacility service) {
    if (service != null &&
        service.professionalId != null &&
        service.professionalId.trim().isNotEmpty) {
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ShowInsuranceListScreen(profId: service.professionalId)))
          .then((value) {});
    }
  }

  Future<RequestState> _getSpecialityList() async {
    if (CommonMethods.catalogueLists == null ||
        CommonMethods.catalogueLists.isEmpty) {
      var result = await UserManager().getSpecialities();
      return result;
    } else {
      return RequestSuccess();
    }
  }

  void _doFilterAndGetFacilities() {
    _getTopFacilities();
  }

  List<DropdownMenuItem<String>> _getSpecialityDropdownItems() {
    if (_specialityDropDownItems != null &&
        _specialityDropDownItems.isNotEmpty) {
      return _specialityDropDownItems;
    }
    _specialityDropDownItems = [];
    CommonMethods.catalogueLists.forEach((element) {
      if (element.speciality != null &&
          element.speciality.trim().isNotEmpty &&
          element.id != null &&
          element.id.trim().isNotEmpty) {
        // if (_selectedSpeciality == null) {
        //   _selectedSpeciality = element.id;
        // }
        _specialityDropDownItems.add(DropdownMenuItem(
          child: Text(_getItem(element.speciality)),
          value: element.id,
        ));
      }
    });
    return _specialityDropDownItems;
  }

  List<SpecialityModel> _getSpecialityItems() {
    if (_specialityItems != null && _specialityItems.isNotEmpty) {
      return _specialityItems;
    }
    _specialityItems = [];
    CommonMethods.catalogueLists.forEach((element) {
      if (element.speciality != null &&
          element.speciality.trim().isNotEmpty &&
          element.id != null &&
          element.id.trim().isNotEmpty) {
        _specialityItems.add(element);
      }
    });
    return _specialityItems;
  }

  String _getItem(String speciality) {
    if (speciality.length > 18) {
      return speciality.substring(0, 18);
    } else {
      return speciality;
    }
  }

  _getModelBottomSheetForServiceList(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17), topRight: Radius.circular(17))),
        builder: (anotherContext) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17)),
                border: Border.all(
                    color: Color(CommonMethods.getColorHexFromStr("#26AF78")),
                    width: 1)),
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 3,
                            top: AppConfig.verticalBlockSize * 1.5),
                        height: 3,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#707070")),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Service",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: 2, bottom: AppConfig.verticalBlockSize * 2.5),
                  height: 0.5,
                  color: Color(CommonMethods.getColorHexFromStr("#707070")),
                  width: double.infinity,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          _selectedSpeciality = _getSpecialityItems()[index].id;
                          _selectedSpecialityName =
                              _getSpecialityItems()[index].speciality;
                          _doFilterAndGetFacilities();
                          Navigator.maybePop(context);
                        },
                        onDoubleTap: () {},
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 0.7),
                          child: Text(
                            _getSpecialityItems()[index].speciality ?? "NA",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      );
                    },
                    itemCount: _getSpecialityItems().length,
                  ),
                )
              ],
            ),
            constraints: BoxConstraints(
                minWidth: 10,
                maxWidth: double.infinity,
                minHeight: AppConfig.verticalBlockSize * 2,
                maxHeight: AppConfig.verticalBlockSize * 50),
          );
        });
  }

  _getModelBottomSheetForFacilityType(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17), topRight: Radius.circular(17))),
        builder: (anotherContext) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17)),
                border: Border.all(
                    color: Color(CommonMethods.getColorHexFromStr("#26AF78")),
                    width: 1)),
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 3,
                            top: AppConfig.verticalBlockSize * 1.5),
                        height: 3,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#707070")),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Facility",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: 2, bottom: AppConfig.verticalBlockSize * 2.5),
                  height: 0.5,
                  color: Color(CommonMethods.getColorHexFromStr("#707070")),
                  width: double.infinity,
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          _userTypeFilter = _facilityTypeList[index].id;
                          _userTypeFilterName =
                              _facilityTypeList[index].speciality;
                          _doFilterAndGetFacilities();
                          Navigator.maybePop(context);
                        },
                        onDoubleTap: () {},
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 0.7),
                          child: Text(
                            _facilityTypeList[index].speciality ?? "NA",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      );
                    },
                    itemCount: _facilityTypeList.length,
                  ),
                )
              ],
            ),
            constraints: BoxConstraints(
                minWidth: 10,
                maxWidth: double.infinity,
                minHeight: AppConfig.verticalBlockSize * 2,
                maxHeight: AppConfig.verticalBlockSize * 38),
          );
        });
  }

  _getModelBottomSheetForLocationType(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(17), topRight: Radius.circular(17))),
        builder: (anotherContext) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17)),
                border: Border.all(
                    color: Color(CommonMethods.getColorHexFromStr("#26AF78")),
                    width: 1)),
            padding: EdgeInsets.symmetric(
                horizontal: AppConfig.horizontalBlockSize * 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            bottom: AppConfig.verticalBlockSize * 3,
                            top: AppConfig.verticalBlockSize * 1.5),
                        height: 3,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Color(
                                CommonMethods.getColorHexFromStr("#707070")),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Facility Location",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: 2, bottom: AppConfig.verticalBlockSize * 2.5),
                  height: 0.5,
                  color: Color(CommonMethods.getColorHexFromStr("#707070")),
                  width: double.infinity,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          _locationFilter = _selectedLocationList[index].id;
                          _locationFilterName =
                              _selectedLocationList[index].speciality;
                          _doFilterAndGetFacilities();
                          Navigator.maybePop(context);
                        },
                        onDoubleTap: () {},
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 0.7),
                          child: Text(
                            _selectedLocationList[index].speciality ?? "NA",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      );
                    },
                    itemCount: _selectedLocationList.length,
                  ),
                )
              ],
            ),
            constraints: BoxConstraints(
                minWidth: 10,
                maxWidth: double.infinity,
                minHeight: AppConfig.verticalBlockSize * 2,
                maxHeight: AppConfig.verticalBlockSize * 28),
          );
        });
  }
}

// Functions

Widget _imageFittedBox(String imageUrl, {BoxFit boxFit = BoxFit.cover}) {
  return CustomWidgets().getImageFromUrl(imageUrl, boxFit: boxFit);
}

Widget _sectionHeading(String text) {
  return Text(
    text ?? "",
    maxLines: 2,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Color(0xff000000),
    ),
  );
}
