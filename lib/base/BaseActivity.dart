import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/blocs/bloc.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/network/Urls.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';
import 'package:plunes/ui/beforeLogin/Registration.dart';
import 'dart:async';
import 'package:plunes/Utils/event_bus.dart';
import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/Http_constants.dart';

/*
 * Created by - Plunes Technologies .
 * Developer - Manvendra Kumar Singh
 * Description - BaseActivity class is used for rendering the Widgets into their child class and having common functions and variables.
 */

// ignore: must_be_immutable
class BaseActivity extends StatefulWidget {
  String applicationType = '',
      machineID = '',
      domain = '',
      name = '',
      deviceId = '';

  BaseActivity({Key key}) : super(key: key);

  final usersType = [
    Constants.generalUser,
    Constants.doctor,
    Constants.hospital
  ]; //, Constants.diagnosticCenter
  PasswordCallback onTap;

  @override
  State<StatefulWidget> createState() => null;

  void showInSnackBar(String value, MaterialColor color,
      GlobalKey<ScaffoldState> _scaffoldKey) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value ?? plunesStrings.somethingWentWrong),
      backgroundColor: color,
    ));
  }

  Widget createTextViews(String label, double fontSize, String colorCode,
      TextAlign textAlign, FontWeight fontWeight) {
    return Text(label,
        textAlign: textAlign,
        style: TextStyle(
            fontSize: fontSize,
            decoration: label == plunesStrings.solutionNearYouMsg
                ? TextDecoration.underline
                : TextDecoration.none,
            color: Color(CommonMethods.getColorHexFromStr(colorCode)),
            fontWeight: fontWeight));
  }

  Widget createTextWithoutColor(String label, double fontSize,
      TextAlign textAlign, FontWeight fontWeight) {
    return Text(label,
        textAlign: textAlign,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight));
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
          width: 1.0,
          color:
              Color(CommonMethods.getColorHexFromStr(colorsFile.lightGrey1))),
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    );
  }

  BoxDecoration myBoxDecorationBottom() {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(CommonMethods.getColorHexFromStr(colorsFile.lightGrey1)),
          width: 1.0,
        ),
      ),
//      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    );
  }

  Widget getSpacer(double top, double bottom) {
    return Container(
      margin: EdgeInsets.only(top: top, bottom: bottom),
    );
  }

  Widget getDividerRow(
      BuildContext context, double top, double bottom, double left) {
    return Container(
      height: 1.0,
      width: MediaQuery.of(context).size.width,
      color: Color(CommonMethods.getColorHexFromStr(colorsFile.lightGrey3)),
      margin: EdgeInsets.only(top: top, left: left, bottom: bottom),
    );
  }

  Widget getLinearProgressView(bool _isAddFetch) {
    return Container(
      height: 5,
      child: Visibility(
        visible: _isAddFetch,
        child: Container(
          height: 5,
          child: LinearProgressIndicator(),
        ),
      ),
    );
  }

  Widget getCrossButton() {
    return Container(
        alignment: Alignment.center,
        width: 25,
        height: 25,
        margin: EdgeInsets.only(right: 0),
        child: getAssetIconWidget(plunesImages.crossIcon, 8, 8, BoxFit.contain),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(12.5),
            )));
  }

  InputDecoration inputDecorationWithoutError(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(width: 0.1, color: Color(0xff01d35a))),
    );
  }

  Widget createTextField(TextEditingController controller, BuildContext context,
      TextInputType inputType, String hintText) {
    return Container(
        padding: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width,
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: inputType,
          controller: controller,
          maxLength: 250,
          maxLines: null,
          maxLengthEnforced: true,
          cursorColor:
              Color(CommonMethods.getColorHexFromStr(colorsFile.black)),
          style: TextStyle(
              height: 1.5,
              fontSize: 18.0,
              color:
                  Color(CommonMethods.getColorHexFromStr(colorsFile.black0))),
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            counterText: '',
          ),
          /*  decoration: inputDecorationWithoutError(hintText)*/
        ));
  }

  InputDecoration myInputBoxDecoration(
      String focusColor,
      String enableColor,
      String label,
      String errorText,
      bool flag,
      TextEditingController passwordController,
      [TextEditingController controller,
      String hint]) {
    return InputDecoration(
      labelText: label,
      errorText: flag ? null : errorText,
      counterText: '',
      hintText: hint,
      contentPadding: EdgeInsets.only(
          left: 10,
          right: (controller ==
                  (passwordController != null
                      ? passwordController
                      : controller))
              ? (controller != null) ? 40 : 10
              : 10,
          top: 5,
          bottom: 5),
/*      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(10.0),
        ),
        borderSide: BorderSide(
            color: Color(CommonMethods.getColorHexFromStr(focusColor)),
            width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(10.0),
        ),
        borderSide: BorderSide(
            color: Color(CommonMethods.getColorHexFromStr(enableColor)),
            width: 1.0),
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          const Radius.circular(10.0),
        ),
        borderSide: BorderSide(
            color: Color(CommonMethods.getColorHexFromStr(enableColor)),
            width: 1.0),
      ),*/
    );
  }

  Widget getCountryBox() {
    return Container(
        height: 45,
        width: 50,
        decoration: myBoxDecorationBottom(),
        child: Center(
            child: createTextViews(plunesStrings.countryCode, 18,
                colorsFile.black0, TextAlign.center, FontWeight.normal)));
  }

  Widget getDefaultButton(
      String text, double _width, double _height, void Function() sendOtp) {
    return Container(
      width: _width,
      height: _height /*text == stringsFile.upload? 35: 42.0*/,
      child: FlatButton(
        onPressed: sendOtp,
        color: Color(hexColorCode.defaultGreen),
        child: Center(
            child: createTextViews(text, 18, colorsFile.white, TextAlign.center,
                FontWeight.normal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }

  Widget getBorderButton(String text, double _width, void Function() sendOtp) {
    return Container(
      width: _width,
      height: text == plunesStrings.upload ? 35 : 42.0,
      child: FlatButton(
        onPressed: sendOtp,
        color: Colors.white,
        child: Center(
            child: createTextViews(text, 18, colorsFile.black0,
                TextAlign.center, FontWeight.normal)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(
                color: Color(
                    CommonMethods.getColorHexFromStr(colorsFile.lightGrey3)))),
      ),
    );
  }

  Widget getBlackBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(left: 10, top: 25),
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget getBlackLocationIcon(double height) {
    return Align(
        alignment: Alignment.center,
        child: Container(
          height: height,
          child: Icon(
            Icons.location_on,
            size: 50,
            color: Colors.black,
          ),
          alignment: Alignment.center,
        ));
  }

  Widget getAppBar(BuildContext context, String title, bool isIosBackButton) {
    return AppBar(
        automaticallyImplyLeading: isIosBackButton,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        leading: isIosBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context, false),
              )
            : Container(),
        title: createTextViews(
            title, 18, colorsFile.black, TextAlign.center, FontWeight.w500));
  }

  Widget getHomeAppBar(BuildContext context, String title, bool isSelected,
      List<String> selectedPositions, String from, _homeScreenState,
      {bool isSolutionPageSelected = false}) {
    return AppBar(
        backgroundColor:
            isSolutionPageSelected ? Colors.transparent : Colors.white,
        elevation: isSolutionPageSelected ? 0.0 : 1.0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        title: createTextViews(
            title, 18, colorsFile.black, TextAlign.center, FontWeight.w500),
        actions: <Widget>[
          isSelected
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => reset(context),
                )
              : Container(),
          (isSelected && from == plunesStrings.notification)
              ? IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    var body = {};
                    body['isYes'] = true;
                    bloc.changeAppBar(context, body);
                  },
                )
              : Container(),
          (isSelected && from == plunesStrings.notification)
              ? Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 20, 20, 20),
                  child: Text('${selectedPositions.length}'),
                )
              : Container()
        ]);
  }

  reset(context) {
    bloc.changeAppBar(context, null);
  }

  Widget getTermsOfUseRow() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          createTextViews(plunesStrings.signUpMsg, 13, colorsFile.lightGrey2,
              TextAlign.center, FontWeight.normal),
          InkWell(
              onTap: () => CommonMethods.launchURL(urls.terms),
              child: Container(
                  child: Text(plunesStrings.termsServices,
                      style: TextStyle(decoration: TextDecoration.underline))))
        ],
      ),
    );
  }

  Widget getAssetImageWidget(String image) {
    return Image.asset(image, fit: BoxFit.cover);
  }

  Widget getAssetIconWidget(
      String image, double height, double width, BoxFit fit) {
    return Image.asset(image, fit: fit, height: height, width: width);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String user in usersType) {
      items.add(new DropdownMenuItem(
          value: user,
          child: createTextViews(user, 18, colorsFile.black0, TextAlign.center,
              FontWeight.normal)));
    }
    return items;
  }

  void statusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
  }

  getApplicationType() {
    CommonMethods.getDeviceInfo().then((String deviceVersion) {
      applicationType = deviceVersion;
      print("====that is device version$deviceVersion");
      return deviceVersion;
    });
  }

  getMachineId() {
    CommonMethods.getDeviceInfo().then((String deviceVersion) {
      machineID = deviceVersion;
      print("====that is device machineid$deviceVersion");
      return deviceVersion;
    });
  }

  getDeviceId() {
    CommonMethods.getDeviceId().then((String deviceId) {
      this.deviceId = deviceId;
    });
  }

  showPhoto(BuildContext context, Photo image) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(/*photo.title*/ ''),
        ),
        body: SizedBox.expand(
          child: Hero(
            tag: image,
            child: GridPhotoViewer(photo: image),
          ),
        ),
      );
    }));
  }
}

///Base State class
abstract class BaseState<T extends BaseActivity> extends State<T>
    with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffoldKey;
  final BlocBase bloc;
  PersistentBottomSheetController _controller2;

  BaseState({@required this.bloc});

  StreamSubscription _loginSubscription;

  @override
  @mustCallSuper
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    scaffoldKey = GlobalKey<ScaffoldState>();
    bloc?.baseStream?.listen((response) {
      if (response is RequestFailed) {
        RequestFailed requestFailed = response;
        if (requestFailed.requestCode == HttpResponseCode.UNAUTHORIZED) {
          handleAuthTokenExpired();
        }
      }
    });

    ///Event bus to handle unauthorized user
    _loginSubscription =
        SessionExpirationEvent().getSessionEventBus().on().listen((data) {
      if (data is RequestFailed) {
        RequestFailed requestFailed = data;
        if (requestFailed.requestCode == HttpResponseCode.UNAUTHORIZED) {
          handleAuthTokenExpired(
              buildContext: scaffoldKey.currentState.context,
              errorMessage: requestFailed.failureCause);
        }
      }
    });

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  void deactivate() {
    _loginSubscription?.cancel();
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    bloc?.dispose();
    super.dispose();
  }

  ///This method used to show error and success Toast.
  ///@Params failureCause, message to show
  ///@Params isSuccess, to notify weather request success or failed
  void showSnackBar(String failureCause, {bool isSuccess = false}) {
    if (failureCause == null || failureCause.isEmpty) {
      return;
    }
    Future.delayed(Duration(milliseconds: 200), () async {
//      _controller2 = CustomWidgets().showScafoldBottomSheet(
//          textToShow: failureCause,
//          scaffoldKey: scaffoldKey,
//          iconColor: isSuccess ? FnpColors.colorPrimary : FnpColors.red,
//          icon: isSuccess ? Icons.done : null);
    });
    Future.delayed(Duration(milliseconds: 1500), () async {
      if (_controller2 != null) _controller2.close();
    });
  }

  /// This method used to show the share system tray
  /// @Params msg, the message visible to user
  void showShareTray(String msg) {
//    CustomWidgets().openSystemShareTray(text: msg);
  }

  /// This method used to handle unauthenticated user throwout app
  /// @Params buildContext, widget context
  /// @Params errorMessage, the message which will be visible in dialog
  void handleAuthTokenExpired(
      {BuildContext buildContext, String errorMessage}) {
//    showDialog(
//      context: scaffoldKey.currentState.context,
//      barrierDismissible: false,
//      builder: (BuildContext context) {
//        return AlertDialog(
//          title: new Text("Session Expired"),
//          content: new Text(errorMessage),
//          actions: <Widget>[
//            new FlatButton(
//              child: new Text("ok"),
//              onPressed: () {
//                Preferences().clearPreferences();
//                Navigator.of(context).pushNamedAndRemoveUntil(
//                    '/login', (Route<dynamic> route) => false);
//              },
//            ),
//          ],
//        );
//      },
//    );
  }

//  Widget getProgressWidget({int progressType}) {
//    return GestureDetector(
//      onTap: () {},
//      child: Container(
//        color: FnpColors.transparentWhite,
//        child: Center(child: CustomWidgets().dashedProgressIndicator()),
//      ),
//    );
//  }
}
