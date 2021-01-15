import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/new_solution_blocs/sol_home_screen_bloc.dart';
import 'package:plunes/models/new_solution_model/solution_home_scr_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/ui/afterLogin/new_solution_screen/enter_facility_details_scr.dart';
import 'package:plunes/ui/afterLogin/solution_screens/bidding_main_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/consultations.dart';
import 'package:plunes/ui/afterLogin/solution_screens/testNproceduresMainScreen.dart';

const kDefaultImageUrl =
    'https://goqii.com/blog/wp-content/uploads/Doctor-Consultation.jpg';

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
  String _failedMessage;
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();

  @override
  void initState() {
    _homeScreenMainBloc = HomeScreenMainBloc();
    _getCategoryData();
    super.initState();
  }

  @override
  void dispose() {
    _homeScreenMainBloc?.dispose();
    super.dispose();
  }

  _getCategoryData() {
    _homeScreenMainBloc.getSolutionHomePageCategoryData();
  }

  _onConsultationButtonClick() {
    return Navigator.push(
        context, MaterialPageRoute(builder: (context) => ConsultationScreen()));
  }

  _onTestAndProcedureButtonClick(String title, bool isProcedure) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestAndProcedureScreen(
                  screenTitle: title,
                  isProcedure: isProcedure,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: HomePageAppBar(
              widget.func,
              () {},
              () {},
              one: _one,
              two: _two,
            ),
            margin: EdgeInsets.only(top: AppConfig.getMediaQuery().padding.top),
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
      child: ListView.builder(
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return _hospitalCard(
            kDefaultImageUrl,
            'Fortis Healthcare',
            'Lorem ipsumLorem ipsumLorem ipsum ipsumLorem Lorem ipsum ipsumLorem Lorem ipsum ipsumLore...View Profile',
          );
        },
        itemCount: 4,
      ),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        color: Color(CommonMethods.getColorHexFromStr("#FAF9F9")),
        child: Column(
          children: [
            Stack(
              children: [
                // background image container
                Container(
                  height: AppConfig.verticalBlockSize * 36,
                  width: AppConfig.horizontalBlockSize * 100,
                  child: _imageFittedBox(
                      _solutionHomeScreenModel?.backgroundImage ?? "",
                      boxFit: BoxFit.cover),
                ),
                // heading text
                Container(
                  margin: EdgeInsets.only(
                      top: AppConfig.verticalBlockSize * 8,
                      left: AppConfig.verticalBlockSize * 4,
                      right: AppConfig.verticalBlockSize * 4),
                  child: RichText(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      text: TextSpan(children: [
                        TextSpan(
                            text: 'Book Your Medical Treatment'
                                    ?.split(" ")
                                    ?.first ??
                                "Book",
                            style: TextStyle(
                                color: PlunesColors.GREENCOLOR, fontSize: 35)),
                        TextSpan(
                            text: _getTextAfterFirstWord(
                                'Book Your Medical Treatment'),
                            style: TextStyle(
                                color: PlunesColors.BLACKCOLOR, fontSize: 35))
                      ])),
                ),
                // search box container
                Container(
                  margin: EdgeInsets.only(
                      top: AppConfig.verticalBlockSize * 23,
                      left: AppConfig.verticalBlockSize * 4,
                      right: AppConfig.verticalBlockSize * 4),
                  height: AppConfig.verticalBlockSize * 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EnterAdditionalUserDetailScr()));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppConfig.horizontalBlockSize * 4),
                          child: Icon(
                            Icons.search,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#B1B1B1")),
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
                                  hintText: 'Search the desired service',
                                  hintStyle: TextStyle(
                                    color: Color(0xffB1B1B1).withOpacity(1.0),
                                    fontSize: AppConfig.mediumFont,
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
              ],
            ),
            // services box row
            _servicesRow(),
            // heading - procedure
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 7,
                  left: AppConfig.horizontalBlockSize * 4.3,
                  right: AppConfig.horizontalBlockSize * 3),
              child: _sectionHeading('Know Your procedure'),
            ),
            _proceduresGrid(),
            // heading - why us
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 5,
                  left: AppConfig.horizontalBlockSize * 4.3,
                  right: AppConfig.horizontalBlockSize * 3),
              child: _sectionHeading('Why Us'),
            ),

            // horizontal list view of cards
            Container(
              height: AppConfig.verticalBlockSize * 44,
              margin: EdgeInsets.all(AppConfig.horizontalBlockSize * 3),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _customBigCard(
                      kDefaultImageUrl, 'Top Rated Medical Facilities'),
                  _customBigCard(kDefaultImageUrl,
                      'Sit back, relax, and plan your treatment in just one click'),
                  _customBigCard(
                      kDefaultImageUrl, 'Top Rated Medical Facilities'),
                  _customBigCard(kDefaultImageUrl,
                      'Sit back, relax, and plan your treatment in just one click'),
                ],
              ),
            ),

            // heading - top facilities
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 5,
                  left: AppConfig.horizontalBlockSize * 4.3,
                  right: AppConfig.horizontalBlockSize * 3),
              child: _sectionHeading('Top facilities'),
            ),

            // vertical view of cards
            _getTopFacilitiesWidget(),

            // heading - top search
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 5,
                  left: AppConfig.horizontalBlockSize * 4.3,
                  right: AppConfig.horizontalBlockSize * 3),
              child: _sectionHeading('Top Search'),
            ),

            // horizontal list view of top search cards
            Container(
              height: AppConfig.verticalBlockSize * 24,
              margin: EdgeInsets.all(AppConfig.horizontalBlockSize * 3),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _topSearchCard(kDefaultImageUrl, 'CT Scan'),
                  _topSearchCard(kDefaultImageUrl, 'CT Scan'),
                  _topSearchCard(kDefaultImageUrl, 'CT Scan'),
                ],
              ),
            ),

            // heading - speciality
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 5,
                  left: AppConfig.horizontalBlockSize * 4.3,
                  right: AppConfig.horizontalBlockSize * 3),
              child: _sectionHeading('Speciality'),
            ),

            // horizontal list view of specialities
            Container(
              height: AppConfig.verticalBlockSize * 28,
              margin: EdgeInsets.all(AppConfig.horizontalBlockSize * 3),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _specialCard(kDefaultImageUrl, 'Pathology',
                      'Lorem ipsumLorem ipsumLorem ipsumLorem Read More'),
                  _specialCard(kDefaultImageUrl, 'Dentist',
                      'Lorem ipsumLorem ipsumLorem ipsumLorem Read More'),
                  _specialCard(kDefaultImageUrl, 'Dermatology',
                      'Lorem ipsumLorem ipsumLorem ipsumLorem Read More'),
                ],
              ),
            ),

            // section heading - vedio
            Container(
                margin: EdgeInsets.only(
                    top: AppConfig.verticalBlockSize * 5,
                    left: AppConfig.horizontalBlockSize * 1,
                    right: AppConfig.horizontalBlockSize * 70),
                child: _sectionHeading('Video')),

            // vedio card
            _hospitalCard(kDefaultImageUrl, 'An Introduction to PLUNES',
                'Discover the best prices from top rated doctors for any medical treatment in Delhi, Noida, Gurgaon, Dwarka at exclusive discounts.'),

            // section heading - reviews
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 5,
                  left: AppConfig.horizontalBlockSize * 2,
                  right: AppConfig.horizontalBlockSize * 60),
              child: _sectionHeading('Reviews'),
            ),

            // review card
          ],
        ),
      ),
    );
  }

  Widget _servicesRow() {
    return Container(
      margin: EdgeInsets.only(top: AppConfig.horizontalBlockSize * 4.35),
      child: Row(
        children: _solutionHomeScreenModel?.data
                ?.map((e) =>
                    _servicesButtonCard(e.categoryImage, e.categoryName, e))
                ?.toList() ??
            [],
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
        child: Card(
          elevation: 10.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: AppConfig.verticalBlockSize * 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    child: _imageFittedBox(url),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: AppConfig.verticalBlockSize * 0.3,
                      left: 2,
                      right: 2),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Functions

Widget _imageFittedBox(String imageUrl, {BoxFit boxFit = BoxFit.cover}) {
  return CustomWidgets().getImageFromUrl(imageUrl, boxFit: boxFit);
}

Widget _sectionHeading(String text) {
  return Text(
    text,
    maxLines: 2,
    style: TextStyle(
      fontSize: AppConfig.largeFont,
      color: Color(0xff000000),
    ),
  );
}

Widget _proceduresGrid() {
  return Container(
    height: AppConfig.verticalBlockSize * 58,
    color: PlunesColors.WHITECOLOR,
    margin: EdgeInsets.only(
        left: AppConfig.horizontalBlockSize * 3,
        right: AppConfig.horizontalBlockSize * 3),
    child: GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 0.93,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _proceduresCard(kDefaultImageUrl, 'CT Scan',
            'Lorem ipsum lorem ipsum lorem ipsum...'),
        _proceduresCard(kDefaultImageUrl, 'Laser Hair Removal',
            'Lorem ipsum lorem ipsum lorem ipsum...'),
        _proceduresCard(kDefaultImageUrl, 'CT Scan',
            'Lorem ipsum lorem ipsum lorem ipsum...'),
        _proceduresCard(kDefaultImageUrl, 'Laser Hair Removal',
            'Lorem ipsum lorem ipsum lorem ipsum...'),
      ],
    ),
  );
}

Widget _proceduresCard(String url, String label, String text) {
  return Card(
    elevation: 10.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            child: _imageFittedBox(url),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          Flexible(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 2,
                  right: AppConfig.horizontalBlockSize * 2,
                  top: AppConfig.verticalBlockSize * 0.1),
              child: Text(
                label,
                textAlign: TextAlign.left,
                maxLines: 2,
                style: TextStyle(fontSize: AppConfig.smallFont),
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
              child: Text(
                text,
                textAlign: TextAlign.left,
                maxLines: 2,
                style: TextStyle(
                  fontSize: AppConfig.verySmallFont,
                  color: Color(0xff444444),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _customBigCard(String imageUrl, String heading) {
  return Container(
    width: AppConfig.horizontalBlockSize * 62,
    margin: EdgeInsets.only(
        right: AppConfig.horizontalBlockSize * 2,
        left: AppConfig.horizontalBlockSize * 1.5),
    child: Column(
      children: [
        Container(
            height: AppConfig.verticalBlockSize * 33,
            child: ClipRRect(
              child: _imageFittedBox(imageUrl),
              borderRadius: BorderRadius.all(Radius.circular(13)),
            )),
        Flexible(
          child: Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(
                top: AppConfig.verticalBlockSize * 2,
                left: AppConfig.horizontalBlockSize * 1),
            child: Text(
              heading,
              maxLines: 3,
              style: TextStyle(
                fontSize: AppConfig.mediumFont,
              ),
            ),
          ),
        )
      ],
    ),
  );
}

Widget _hospitalCard(String imageUrl, String label, String text) {
  return Container(
    margin: EdgeInsets.symmetric(
        horizontal: AppConfig.horizontalBlockSize * 3,
        vertical: AppConfig.verticalBlockSize * 1),
    height: AppConfig.verticalBlockSize * 38,
    child: Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        children: [
          Container(
            child: ClipRRect(
              child: _imageFittedBox(imageUrl),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10)),
            ),
            height: AppConfig.verticalBlockSize * 26,
            width: double.infinity,
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
                    label,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: AppConfig.mediumFont,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                      ),
                      Text(
                        " 4.5",
                        style: TextStyle(
                          fontSize: 18,
                          color: PlunesColors.BLACKCOLOR,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                  left: AppConfig.horizontalBlockSize * 2,
                  right: AppConfig.horizontalBlockSize * 2,
                  top: AppConfig.verticalBlockSize * 0.3),
              child: Text(
                text,
                maxLines: 2,
                style: TextStyle(
                  fontSize: AppConfig.verySmallFont,
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _topSearchCard(String imageUrl, String text) {
  return Container(
    width: AppConfig.horizontalBlockSize * 45,
    child: Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Container(
            height: AppConfig.verticalBlockSize * 15,
            child: ClipRRect(
              child: _imageFittedBox(imageUrl),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
          ),
          Flexible(
            child: ListTile(
              title: Text(
                text,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppConfig.mediumFont),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

Widget _specialCard(String imageUrl, String label, String text) {
  return Container(
    width: AppConfig.horizontalBlockSize * 45,
    child: Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Container(
            child: ClipRRect(
              child: _imageFittedBox(imageUrl),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
          ),
          ListTile(
            title: Text(
              label,
              maxLines: 2,
              style: TextStyle(fontSize: AppConfig.smallFont),
            ),
            subtitle: Text(
              text,
              maxLines: 3,
              style: TextStyle(fontSize: AppConfig.verySmallFont),
            ),
          )
        ],
      ),
    ),
  );
}
