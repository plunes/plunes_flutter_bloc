import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';

import 'HomeScreen.dart';
/*
 * Created by  - Plunes Technologies.
 * Developer   - Manvendra Kumar Singh
 * Description - NotificationScreen class contains all the in-app notification, which is coming from different aspects of the application. Ex.: Booking,
 *               Payment Completion, PLOCKR notification, Appointment Notification, Negotiation Notification.
 *
 */

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
        backgroundColor: Colors.white,
        body: Container(
          child: StreamBuilder(
            stream: bloc.notificationApiFetcherList,
            builder: ((context, snapshot) {
              items = snapshot.data;
              if (snapshot.hasData) {
                if (items.posts.length == 0)
                  return Center(
                    child: Text(stringsFile.noRecordsFound),
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
      itemCount: snapshot.data.posts.length,
      itemBuilder: (context, index) {
        return rowLayout(snapshot.data.posts[index]);
      },
    );
  }

  Widget rowLayout(result) {
    int removePosition = selectedPositions.indexOf(result.id.toString());
    return InkWell(
      onTap: () => addRemoveSelectedItem(result, removePosition),
      onLongPress: () {
        reset();
        isSelected = true;
        addRemoveSelectedItem(result, removePosition);
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: Card(
          elevation: 2,
          semanticContainer: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Container(
              margin: EdgeInsets.only(
                  left: selectedPositions.indexOf(result.id.toString()) > -1
                      ? 5.0
                      : 0.0),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 0, right: 10),
                    child: result.senderImageUrl != '' &&
                            !result.senderImageUrl.contains("default")
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(result.senderImageUrl),
                          )
                        : Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                                (result.senderName != ''
                                        ? CommonMethods.getInitialName(
                                            result.senderName)
                                        : '')
                                    .toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal)),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              gradient: new LinearGradient(
                                  colors: [
                                    Color(0xffababab),
                                    Color(0xff686868)
                                  ],
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  stops: [0.0, 1.0],
                                  tileMode: TileMode.clamp),
                            )),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          result.senderName,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            result.notification,
                            maxLines: null,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
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
                      style: TextStyle(fontSize: 13),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future addRemoveSelectedItem(result, int removePosition) async {
    if (isSelected) {
      List<String> list = new List();
      setState(() {
        String pos = result.id.toString();
        if (removePosition > -1) {
          selectedPositions.remove(pos);
        } else {
          selectedPositions.add(pos);
        }
      });
      if (selectedPositions.length == 0) reset();
      list = selectedPositions;
      var body = {};
      body['selectedItemList'] = list;
      body['isSelected'] = isSelected;
      bloc.changeAppBar(context, body);
    } else {
      isSelected = false;
      bloc.changeAppBar(context, null);
      if (result.notificationType == 'solution' ||
          result.notificationType == 'price') {
//        Navigator.push(context,MaterialPageRoute(builder: (context) => BiddingActivity(screen: 0)));
      } else if (result.notificationType == 'booking') {
//        Navigator.push(context, MaterialPageRoute(builder: (context) => Appointments(screen: 0)));
      } else if (result.notificationType == 'plockr') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(screen: "plocker")));
      }
    }
  }

  void reset() {
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
            context, stringsFile.deleteNotificationMsg, this);
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
