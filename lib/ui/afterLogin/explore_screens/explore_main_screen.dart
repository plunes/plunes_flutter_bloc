// import 'dart:async';
//
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:dots_indicator/dots_indicator.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:plunes/Utils/CommonMethods.dart';
// import 'package:plunes/Utils/Constants.dart';
// import 'package:plunes/Utils/app_config.dart';
// import 'package:plunes/Utils/custom_widgets.dart';
// import 'package:plunes/Utils/event_bus.dart';
// import 'package:plunes/base/BaseActivity.dart';
// import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
// import 'package:plunes/blocs/explore_bloc/explore_main_bloc.dart';
// import 'package:plunes/firebase/FirebaseNotification.dart';
// import 'package:plunes/models/explore/explore_main_model.dart';
// import 'package:plunes/requester/request_states.dart';
// import 'package:plunes/res/AssetsImagesFile.dart';
// import 'package:plunes/res/ColorsFile.dart';
// import 'package:plunes/res/StringsFile.dart';
// import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
// import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';
// import 'package:plunes/ui/afterLogin/solution_screens/bidding_screen.dart';
//
// // ignore: must_be_immutable
// class ExploreMainScreen extends BaseActivity {
//   bool hasAppBar;
//
//   ExploreMainScreen({this.hasAppBar});
//
//   @override
//   _ExploreMainScreenState createState() => _ExploreMainScreenState();
// }
//
// class _ExploreMainScreenState extends BaseState<ExploreMainScreen> {
//   var _decorator = DotsDecorator(
//       activeColor: PlunesColors.BLACKCOLOR,
//       color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));
//
//   double _currentDotPosition = 0.0;
//   final CarouselController _controller = CarouselController();
//   StreamController _streamController;
//   ExploreMainBloc _exploreMainBloc;
//   ExploreOuterModel _exploreModel;
//   String _failedMessage;
//
//   CartMainBloc _cartBloc;
//
//   @override
//   void initState() {
//     _cartBloc = CartMainBloc();
//     _exploreMainBloc = ExploreMainBloc();
//     _getExploreData();
//     _currentDotPosition = 0.0;
//     _streamController = StreamController.broadcast();
//     EventProvider().getSessionEventBus().on<ScreenRefresher>().listen((event) {
//       if (event != null &&
//           event.screenName == FirebaseNotification.exploreScreen &&
//           mounted) {
//         _getExploreData();
//       }
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _streamController?.close();
//     _exploreMainBloc?.dispose();
//     _cartBloc?.dispose();
//     _whyPlunesWidgets = [];
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<RequestState>(
//           initialData: (_exploreModel == null || _exploreModel.data == null)
//               ? RequestInProgress()
//               : null,
//           stream: _exploreMainBloc.baseStream,
//           builder: (context, snapshot) {
//             if (snapshot.data is RequestSuccess) {
//               RequestSuccess successObject = snapshot.data;
//               _exploreModel = successObject.response;
//             } else if (snapshot.data is RequestFailed) {
//               RequestFailed _failedObj = snapshot.data;
//               _failedMessage = _failedObj?.failureCause;
//             } else if (snapshot.data is RequestInProgress) {
//               return CustomWidgets().getProgressIndicator();
//             }
//             return (_exploreModel == null ||
//                     _exploreModel.data == null ||
//                     _exploreModel.data.isEmpty)
//                 ? CustomWidgets().errorWidget(_failedMessage,
//                     onTap: () => _getExploreData(), isSizeLess: true)
//                 : _getBody();
//           }),
//       appBar: (widget.hasAppBar == null || !widget.hasAppBar)
//           ? null
//           : widget.getAppBar(context, PlunesStrings.explore, true),
//     );
//   }
//
//   List<Widget> _whyPlunesWidgets = [
//     Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(8)),
//         color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//       ),
//       padding:
//           EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
//       margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//       child: Row(
//         children: <Widget>[
//           Container(
//             child: Image.asset(PlunesImages.zeroCostEmiIcon),
//             height: AppConfig.verticalBlockSize * 3,
//             width: AppConfig.horizontalBlockSize * 6,
//             margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//           ),
//           Text(
//             "Zero cost EMI",
//             style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
//           )
//         ],
//       ),
//     ),
//     Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(8)),
//         color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//       ),
//       padding:
//           EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
//       margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//       child: Row(
//         children: <Widget>[
//           Container(
//             child: Image.asset(PlunesImages.paymentRefIcon),
//             height: AppConfig.verticalBlockSize * 3,
//             width: AppConfig.horizontalBlockSize * 6,
//             margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//           ),
//           Text(
//             "Payment Refundable",
//             style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
//           )
//         ],
//       ),
//     ),
// //    Container(
// //      decoration: BoxDecoration(
// //        borderRadius: BorderRadius.all(Radius.circular(8)),
// //        color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
// //      ),
// //      padding:
// //          EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
// //      margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
// //      child: Row(
// //        children: <Widget>[
// //          Container(
// //            child: Image.asset(PlunesImages.firstConslFree),
// //            height: AppConfig.verticalBlockSize * 3,
// //            width: AppConfig.horizontalBlockSize * 6,
// //            margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
// //          ),
// //          Text(
// //            "First consultation free",
// //            style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
// //          )
// //        ],
// //      ),
// //    ),
//     Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(8)),
//         color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//       ),
//       padding:
//           EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
//       margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//       child: Row(
//         children: <Widget>[
//           Container(
//             child: Image.asset(PlunesImages.prefTimeIcon),
//             height: AppConfig.verticalBlockSize * 3,
//             width: AppConfig.horizontalBlockSize * 6,
//             margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//           ),
//           Text(
//             "Preferred timing as per your availability",
//             style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
//           )
//         ],
//       ),
//     ),
//     Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(8)),
//         color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//       ),
//       padding:
//           EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
//       margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//       child: Row(
//         children: <Widget>[
//           Container(
//             child: Image.asset(PlunesImages.freeTeleConsImg),
//             height: AppConfig.verticalBlockSize * 3,
//             width: AppConfig.horizontalBlockSize * 6,
//             margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//           ),
//           Text(
//             "Free telephonic consultation",
//             style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
//           )
//         ],
//       ),
//     ),
//     Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(8)),
//         color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//       ),
//       padding:
//           EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize * 2),
//       margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//       child: Row(
//         children: <Widget>[
//           Container(
//             child: Image.asset(PlunesImages.plunesVerifiedImg),
//             height: AppConfig.verticalBlockSize * 3,
//             width: AppConfig.horizontalBlockSize * 6,
//             margin: EdgeInsets.only(right: AppConfig.horizontalBlockSize * 2),
//           ),
//           Text(
//             "Plunes verified",
//             style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 13),
//           )
//         ],
//       ),
//     ),
//   ];
//
//   Widget _getBody() {
//     return Container(
//       color: PlunesColors.WHITECOLOR,
//       child: ListView(
//         shrinkWrap: true,
//         children: <Widget>[
//           _getWhyPlunesView(),
//           _exploreModel.data.first.section2 != null &&
//                   _exploreModel.data.first.section2.elements != null &&
//                   _exploreModel.data.first.section2.elements.isNotEmpty
//               ? _getSectionTwoWidget(_exploreModel.data.first.section2)
//               : Container(),
//           _exploreModel.data.first.section3 != null &&
//                   _exploreModel.data.first.section3.elements != null &&
//                   _exploreModel.data.first.section3.elements.isNotEmpty
//               ? _getSectionThreeWidget(_exploreModel.data.first.section3)
//               : Container(),
//           _exploreModel.data.first.section4 != null &&
//                   _exploreModel.data.first.section4.elements != null &&
//                   _exploreModel.data.first.section4.elements.isNotEmpty
//               ? _getSectionFourWidget(_exploreModel.data.first.section4)
//               : Container(),
//           _exploreModel.data.first.section5 != null &&
//                   _exploreModel.data.first.section5.elements != null &&
//                   _exploreModel.data.first.section5.elements.isNotEmpty
//               ? _getSectionFiveWidget(_exploreModel.data.first.section5)
//               : Container(),
//         ],
//       ),
//     );
//   }
//
//   Widget _getWhyPlunesView() {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.only(
//           left: AppConfig.horizontalBlockSize * 4,
//           right: AppConfig.horizontalBlockSize * 4,
//           top: AppConfig.verticalBlockSize * 2),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             PlunesStrings.whyPlunes,
//             textAlign: TextAlign.left,
//             style: TextStyle(
//                 color: PlunesColors.BLACKCOLOR,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16),
//           ),
//           Container(
//             height: AppConfig.verticalBlockSize * 8,
//             margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
//             child: ListView.builder(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, index) {
//                 return _whyPlunesWidgets[index];
//               },
//               itemCount: _whyPlunesWidgets?.length ?? 0,
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _getSectionTwoWidget(Section3 sectionTwo) {
//     return Container(
//       margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
//       child: Column(
//         children: <Widget>[
//           Container(
//             alignment: Alignment.topLeft,
//             child: Text(
//               sectionTwo.heading ?? PlunesStrings.NA,
//               style: TextStyle(
//                   color: PlunesColors.BLACKCOLOR,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16),
//             ),
//             margin: EdgeInsets.symmetric(
//                 vertical: AppConfig.verticalBlockSize * 2,
//                 horizontal: AppConfig.horizontalBlockSize * 4),
//           ),
//           CarouselSlider.builder(
//             itemCount:
//                 sectionTwo.elements.length > 8 ? 8 : sectionTwo.elements.length,
//             carouselController: _controller,
//             options: CarouselOptions(
//                 height: AppConfig.verticalBlockSize * 28,
//                 aspectRatio: 16 / 9,
//                 initialPage: 0,
//                 enableInfiniteScroll: false,
//                 pageSnapping: true,
//                 reverse: false,
//                 enlargeCenterPage: true,
//                 viewportFraction: 1.0,
//                 scrollDirection: Axis.horizontal,
//                 onPageChanged: (index, _) {
//                   if (_currentDotPosition.toInt() != index) {
//                     _currentDotPosition = index.toDouble();
//                     _streamController?.add(null);
//                   }
//                 }),
//             itemBuilder: (BuildContext context, int itemIndex) => Container(
// //              color: Colors.grey,
//               width: double.infinity,
//               child: InkWell(
//                 onTap: () {
//                   if (sectionTwo.elements[itemIndex].serviceName != null &&
//                       sectionTwo.elements[itemIndex].serviceName
//                           .trim()
//                           .isNotEmpty) {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => SolutionBiddingScreen(
//                                 searchQuery: sectionTwo.elements[itemIndex]
//                                     .serviceName))).then((value) {
//                       _getCartCount();
//                     });
//                   }
//                 },
//                 child: Container(
//                   margin: EdgeInsets.all(10.0),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: CustomWidgets().getImageFromUrl(
//                         sectionTwo.elements[itemIndex].imgUrl,
//                         boxFit: BoxFit.fill),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           StreamBuilder<Object>(
//               stream: _streamController.stream,
//               builder: (context, snapshot) {
//                 return Container(
//                   margin:
//                       EdgeInsets.only(top: AppConfig.verticalBlockSize * 0.5),
//                   child: DotsIndicator(
//                     dotsCount: sectionTwo.elements.length > 8
//                         ? 8
//                         : sectionTwo.elements.length,
//                     position: _currentDotPosition,
//                     axis: Axis.horizontal,
//                     decorator: _decorator,
//                     onTap: (pos) {
//                       _controller.animateToPage(pos.toInt(),
//                           curve: Curves.easeInOut,
//                           duration: Duration(milliseconds: 300));
//                       _currentDotPosition = pos;
//                       _streamController?.add(null);
//                       return;
//                     },
//                   ),
//                 );
//               })
//         ],
//       ),
//     );
//   }
//
//   Widget _getSectionThreeWidget(Section3 section3) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
//       child: Column(
//         children: <Widget>[
//           Container(
//             alignment: Alignment.topLeft,
//             child: Text(
//               section3?.heading ?? PlunesStrings.NA,
//               style: TextStyle(
//                   color: PlunesColors.BLACKCOLOR,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16),
//             ),
//             margin: EdgeInsets.symmetric(
//                 vertical: AppConfig.verticalBlockSize * 1.5,
//                 horizontal: AppConfig.horizontalBlockSize * 4),
//           ),
//           Container(
//             height: AppConfig.verticalBlockSize * 32,
//             margin: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
//             child: ListView.builder(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     if (section3.elements[index].userType != null &&
//                         section3.elements[index].userId != null) {
//                       Widget route;
//                       if (section3.elements[index].userType.toLowerCase() ==
//                           Constants.doctor.toString().toLowerCase()) {
//                         route =
//                             DocProfile(userId: section3.elements[index].userId);
//                       } else {
//                         route = HospitalProfile(
//                             userID: section3.elements[index].userId);
//                       }
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) => route));
//                     }
//                     return;
//                   },
//                   child: Card(
//                     color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Container(
//                       width: AppConfig.horizontalBlockSize * 42,
//                       margin: EdgeInsets.symmetric(
//                           horizontal: AppConfig.horizontalBlockSize * 3,
//                           vertical: AppConfig.verticalBlockSize * 1.2),
//                       child: Column(
//                         children: <Widget>[
//                           Container(
//                             width: double.infinity,
//                             height: AppConfig.verticalBlockSize * 15,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: CustomWidgets().getImageFromUrl(
//                                   section3.elements[index].imgUrl,
//                                   boxFit: BoxFit.cover),
//                             ),
//                           ),
//                           Container(
//                             alignment: Alignment.center,
//                             child: Text(
//                               section3.elements[index].name ?? PlunesStrings.NA,
//                               maxLines: 2,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: PlunesColors.BLACKCOLOR,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 15),
//                             ),
//                             margin: EdgeInsets.symmetric(
//                                 vertical: AppConfig.verticalBlockSize * 1.5,
//                                 horizontal: AppConfig.horizontalBlockSize * 4),
//                           ),
//                           Flexible(
//                             child: Container(
//                               alignment: Alignment.center,
//                               child: Text(
//                                 section3.elements[index].subHeading ??
//                                     PlunesStrings.NA,
//                                 maxLines: 2,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: PlunesColors.BLACKCOLOR,
//                                     fontWeight: FontWeight.normal,
//                                     fontSize: 13),
//                               ),
//                               margin: EdgeInsets.symmetric(
//                                   vertical: AppConfig.verticalBlockSize * 0.2,
//                                   horizontal:
//                                       AppConfig.horizontalBlockSize * 4),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               itemCount: section3.elements?.length ?? 0,
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _getSectionFourWidget(Section3 section4) {
//     return Container(
//       padding: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
//       height: AppConfig.verticalBlockSize * 10,
//       child: ListView.builder(
//         itemBuilder: (context, index) {
//           return InkWell(
//             onTap: () {
//               if (section4.elements[index].serviceName != null &&
//                   section4.elements[index].serviceName.trim().isNotEmpty) {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => SolutionBiddingScreen(
//                             searchQuery: section4
//                                 .elements[index].serviceName))).then((value) {
//                   _getCartCount();
//                 });
//               }
//             },
//             child: Card(
//               color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: Container(
//                 width: AppConfig.horizontalBlockSize * 90,
//                 padding: EdgeInsets.symmetric(
//                     horizontal: AppConfig.horizontalBlockSize * 2.5),
//                 child: Row(
//                   children: <Widget>[
//                     InkWell(
//                       onTap: () {
//                         return;
//                       },
//                       onDoubleTap: () {},
//                       child: (section4.elements[index].imgUrl != null &&
//                               section4.elements[index].imgUrl.isNotEmpty &&
//                               section4.elements[index].imgUrl.contains("http"))
//                           ? CircleAvatar(
//                               backgroundColor: Colors.transparent,
//                               child: Container(
//                                 height: AppConfig.horizontalBlockSize * 14,
//                                 width: AppConfig.horizontalBlockSize * 14,
//                                 child: ClipOval(
//                                     child: CustomWidgets().getImageFromUrl(
//                                         section4.elements[index].imgUrl,
//                                         boxFit: BoxFit.fill,
//                                         placeHolderPath:
//                                             PlunesImages.doc_placeholder)),
//                               ),
//                               radius: AppConfig.horizontalBlockSize * 7,
//                             )
//                           : CustomWidgets().getProfileIconWithName(
//                               section4.elements[index].serviceName ??
//                                   PlunesStrings.NA,
//                               14,
//                               14,
//                             ),
//                     ),
//                     Expanded(
//                         child: Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: AppConfig.horizontalBlockSize * 3),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Text(
//                             section4.elements[index].serviceName ??
//                                 PlunesStrings.NA,
//                             maxLines: 1,
//                             style: TextStyle(
//                                 color: PlunesColors.BLACKCOLOR,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w500),
//                           ),
//                           Text(
//                             section4.elements[index].subHeading ??
//                                 PlunesStrings.NA,
//                             maxLines: 1,
//                             style: TextStyle(
//                                 color: PlunesColors.BLACKCOLOR,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.normal),
//                           )
//                         ],
//                       ),
//                     )),
//                     Text(
//                       "View",
//                       style: TextStyle(
//                           color: PlunesColors.GREENCOLOR,
//                           fontSize: 14,
//                           fontWeight: FontWeight.normal),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//         itemCount: section4.elements?.length ?? 0,
//         shrinkWrap: true,
//         scrollDirection: Axis.horizontal,
//       ),
//     );
//   }
//
//   Widget _getSectionFiveWidget(Section3 section5) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2),
//       child: Column(
//         children: <Widget>[
//           Container(
//             alignment: Alignment.topLeft,
//             child: Text(
//               section5.heading ?? PlunesStrings.NA,
//               style: TextStyle(
//                   color: PlunesColors.BLACKCOLOR,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 16),
//             ),
//             margin: EdgeInsets.symmetric(
//                 vertical: AppConfig.verticalBlockSize * 1.5,
//                 horizontal: AppConfig.horizontalBlockSize * 4),
//           ),
//           Container(
//             height: AppConfig.verticalBlockSize * 35,
//             margin: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
//             child: ListView.builder(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {
//                     if (section5.elements[index].serviceName != null &&
//                         section5.elements[index].serviceName
//                             .trim()
//                             .isNotEmpty) {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => SolutionBiddingScreen(
//                                   searchQuery: section5.elements[index]
//                                       .serviceName))).then((value) {
//                         _getCartCount();
//                       });
//                     }
//                   },
//                   child: Card(
//                     color: Color(CommonMethods.getColorHexFromStr("#F5F5F5")),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Container(
//                       width: AppConfig.horizontalBlockSize * 48,
//                       margin: EdgeInsets.symmetric(
//                           horizontal: AppConfig.horizontalBlockSize * 3,
//                           vertical: AppConfig.verticalBlockSize * 1.2),
//                       child: Column(
//                         children: <Widget>[
//                           Container(
//                             alignment: Alignment.center,
//                             color: Colors.transparent,
//                             child: CustomWidgets().getImageFromUrl(
//                                 section5.elements[index].imgUrl,
//                                 boxFit: BoxFit.cover),
//                           ),
//                           Container(
//                             alignment: Alignment.center,
//                             child: Text(
//                               section5.elements[index].serviceName ??
//                                   PlunesStrings.NA,
//                               maxLines: 2,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: PlunesColors.BLACKCOLOR,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 15),
//                             ),
//                             margin: EdgeInsets.symmetric(
//                                 vertical: AppConfig.verticalBlockSize * 1.5,
//                                 horizontal: AppConfig.horizontalBlockSize * 4),
//                           ),
//                           Container(
//                             alignment: Alignment.center,
//                             child: Text(
//                               section5.elements[index].subHeading1 ??
//                                   PlunesStrings.NA,
//                               maxLines: 2,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                   color: PlunesColors.BLACKCOLOR,
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 13),
//                             ),
//                             margin: EdgeInsets.symmetric(
//                                 vertical: AppConfig.verticalBlockSize * 0.4,
//                                 horizontal: AppConfig.horizontalBlockSize * 4),
//                           ),
//                           Flexible(
//                             child: Container(
//                               alignment: Alignment.topCenter,
//                               child: Text(
//                                 section5.elements[index].subHeading2 ??
//                                     PlunesStrings.NA,
//                                 maxLines: 2,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                     color: PlunesColors.BLACKCOLOR,
//                                     fontWeight: FontWeight.normal,
//                                     fontSize: 13),
//                               ),
//                               margin: EdgeInsets.symmetric(
//                                   horizontal:
//                                       AppConfig.horizontalBlockSize * 4),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               itemCount: section5.elements?.length ?? 0,
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   void _getExploreData() {
//     _failedMessage = null;
//     _exploreMainBloc.getExploreData();
//   }
//
//   void _getCartCount() {
//     _cartBloc.getCartCount();
//   }
// }
