import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/firebase/FirebaseNotification.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:plunes/ui/afterLogin/appointment_screens/appointment_main_screen.dart';
import 'package:plunes/ui/afterLogin/solution_screens/negotiate_waiting_screen.dart';
import 'HomeScreen.dart';
/*
 * Created by  - Plunes Technologies.
 * Developer   - Manvendra Kumar Singh
 * Description - NotificationScreen class contains all the in-app notification, which is coming from different aspects of the application. Ex.: Booking,
 *               Payment Completion, PLOCKR notification, Appointment Notification, Negotiation Notification.
 *
 */

// ignore: must_be_immutable
class NotificationScreen extends BaseActivity {
  static const tag = 'notificationscreen';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    implements DialogCallBack {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth;
  bool isSelected = false;
  List<String> selectedPositions = new List();
  AllNotificationsPost items;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    bloc.disposeNotificationApiStream();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: PlunesColors.WHITECOLOR,
        body: Container(
          child: StreamBuilder(
            stream: bloc.notificationApiFetcherList,
            builder: ((context, snapshot) {
              items = snapshot.data;
              if (snapshot.hasData) {
                if (items.posts.length == 0)
                  return Center(
                    child: Text(plunesStrings.noRecordsFound,
                        style: TextStyle(fontSize: AppConfig.smallFont)),
                  );
                else
                  return buildList(snapshot);
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
          ),
        ));
  }

  Widget buildList(AsyncSnapshot<AllNotificationsPost> snapshot) {
    return ListView.builder(
      padding: EdgeInsets.only(top:AppConfig.verticalBlockSize*2),
      itemCount: snapshot.data.posts.length,
      itemBuilder: (context, index) {
        return rowLayout(snapshot.data.posts[index]);
      },
    );
  }

  Widget rowLayout(PostsData result) {
    int removePosition = selectedPositions.indexOf(result.id.toString());
    return InkWell(
      onTap: () => addRemoveSelectedItem(result, removePosition),
//      onLongPress: () {
//        reset();
//        isSelected = true;
//        addRemoveSelectedItem(result, removePosition);
//      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppConfig.horizontalBlockSize*3,),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 0, right: 10),
                  child: result.senderImageUrl != '' &&
                          !result.senderImageUrl.contains("default")
                      ? CircleAvatar(
                          radius: AppConfig.horizontalBlockSize * 5,
                          backgroundImage:
                              NetworkImage(result.senderImageUrl),
                        )
                      : CustomWidgets().getProfileIconWithName(result.senderName ,14, 14),

//              Container(
////                            height: AppConfig.verticalBlockSize*4,
////                            width: AppConfig.horizontalBlockSize*8,
//                      padding: EdgeInsets.all(
//                          AppConfig.horizontalBlockSize * 1.6),
//                      alignment: Alignment.center,
//                      child: Text(
//                          (result.senderName != ''
//                                  ? CommonMethods.getInitialName(
//                                      result.senderName)
//                                  : '')
//                              .toUpperCase(),
//                          style: TextStyle(
//                              color: Colors.white,
//                              fontSize: AppConfig.smallFont,
//                              fontWeight: FontWeight.normal)),
//                      decoration: BoxDecoration(
//                        borderRadius: BorderRadius.all(Radius.circular(
//                            AppConfig.horizontalBlockSize * 5)),
//                        gradient: new LinearGradient(
//                            colors: [
//                              Color(0xffababab),
//                              Color(0xff686868)
//                            ],
//                            begin: FractionalOffset.topCenter,
//                            end: FractionalOffset.bottomCenter,
//                            stops: [0.0, 1.0],
//                            tileMode: TileMode.clamp),
//                      )),
    ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        result.senderName,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: AppConfig.smallFont,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        width: AppConfig.horizontalBlockSize * 65,
                        child: Text(
                          result.notification,
                          maxLines: null,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: AppConfig.smallFont),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.topRight,
                  child: Text(
                    CommonMethods.getDuration(result.createdTime),
                    style: TextStyle(fontSize: AppConfig.verySmallFont - 2),
                  ),
                )
              ],
            ),
           CustomWidgets().getSeparatorLine(),
//            Padding(
//              padding: EdgeInsets.only(top:AppConfig.verticalBlockSize*2),
//            ),
//            Container(
//              width: double.infinity,
//              height: 0.5,
//              color: PlunesColors.GREYCOLOR,
//            )
          ],
        ),
      ),
    );
  }

  Future addRemoveSelectedItem(PostsData result, int removePosition) async {
//    if (isSelected) {
//      List<String> list = new List();
//      setState(() {
//        String pos = result.id.toString();
//        if (removePosition > -1) {
//          selectedPositions.remove(pos);
//        } else {
//          selectedPositions.add(pos);
//        }
//      });
//      if (selectedPositions.length == 0) reset();
//      list = selectedPositions;
//      var body = {};
//      body['selectedItemList'] = list;
//      body['isSelected'] = isSelected;
//      bloc.changeAppBar(context, body);
//    } else {
//      isSelected = false;
//      bloc.changeAppBar(context, null);
    print("Type of Notifcation:" + result?.notificationType);
    print("Type of result" + result?.toString());

    if (result.notificationType == FirebaseNotification.solutionScreen &&
        UserManager().getUserDetails().userType == Constants.user) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BiddingLoading(
                    catalogueData: CatalogueData(
                        solutionId: result.id, isFromNotification: true),
                  )));
    } else if (result.notificationType == FirebaseNotification.bookingScreen) {
      print("notification id is ${result.notificationId}");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AppointmentMainScreen(
                    bookingId: result.notificationId,
                  )));
    } else if ((result.notificationType == FirebaseNotification.insightScreen ||
            result.notificationType == FirebaseNotification.solutionScreen) &&
        UserManager().getUserDetails().userType != Constants.user) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(screenNo: Constants.homeScreenNumber)),
          (_) => false);
    } else if (result.notificationType == FirebaseNotification.plockrScreen) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(screenNo: Constants.plockerScreenNumber)),
          (_) => false);
    }
    //  }
  }

  void reset() {
    if (mounted)
      setState(() {
        if (selectedPositions.length > 0) {
          selectedPositions.clear();
          isSelected = false;
        }
      });
  }

  void initialize() {
    bloc.fetchNotificationData(context, this);
    bloc.deleteListenerFetcher.listen((data) {
      if (data == null)
        reset();
      else if (data != null && data['isYes'] != null && data['isYes']) {
        CommonMethods.confirmationDialog(
            context, plunesStrings.deleteNotificationMsg, this);
      }
    });
  }

  @override
  dialogCallBackFunction(String action) {
    if (action == 'CANCEL') {
      reset();
    } else {
      for (int i = 0; i < items.posts.length; i++) {
        bool flag = false;
        for (int j = 0; j < selectedPositions.length; j++) {
          if (!flag && items.posts[i].id.toString() == selectedPositions[j]) {
            items.posts.removeAt(i);
            flag = true;
            i--;
          }
        }
      }
      reset();
      bloc.notificationApiFetcher.sink.add(items);
    }
  }
}
