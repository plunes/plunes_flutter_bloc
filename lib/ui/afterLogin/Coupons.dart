import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Preferences.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/StringsFile.dart';

class Coupons extends BaseActivity {
  static const tag = '/coupons';

  @override
  _CouponsState createState() => _CouponsState();
}

class _CouponsState extends State<Coupons> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth;
  Preferences _preferences;
  List<dynamic> couponsList = new List();

  final couponCodeController = new TextEditingController();
  bool isSuccess = false,
      isProgressing = false,
      isButtonEnable = false,
      showCouponScreen = true,
      hasCoupons = false;
  String user_token = "";
  String user_id = "";
  String credit = "";
  String refer_code = "", title = plunesStrings.coupons;
  bool isFetchingData = true;
  var couponName = '',
      consulCount = '',
      testCount = '',
      consultationImage = 'assets/images/consultaion_icon.png',
      consultationBgImage = 'assets/images/blue_bg.png',
      testIcon = 'assets/images/test_icon.png';

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    _preferences = Preferences();
    getCouponsHistory();
  }

  Widget couponScreenView() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Please enter code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xff262626),
                                fontSize: 22,
                                fontWeight: FontWeight.normal)),
                        Container(
                          margin: EdgeInsets.only(
                              left: 80, right: 80, bottom: 10, top: 50),
                          child: TextField(
                            controller: couponCodeController,
                            textAlign: TextAlign.center,
                            maxLength: 10,
                            onChanged: (text) {
                              setState(() {
                                if (text.length > 0)
                                  isButtonEnable = true;
                                else
                                  isButtonEnable = false;
                              });
                            },
                            textCapitalization: TextCapitalization.characters,
                            style: TextStyle(fontSize: 18),
                            cursorColor: Color(0xff01d35a),
                            decoration: InputDecoration(
                                hintText: 'Enter Coupon Code',
                                counterText: '',
                                hintStyle: TextStyle(
                                    color: Color(
                                        CommonMethods.getColorHexFromStr(
                                            '#8A8A8A')))),
                          ),
                        ),
                      ],
                    ),
                  ))),
          Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
//                    CommonMethods.showToast("Promo Code Applied.", Colors.green);
                  if (isButtonEnable) saveCouponCode();
                },
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: isProgressing
                    ? SpinKitThreeBounce(
                        color: Color(0xff01d35a),
                        size: 30.0,
                        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                      )
                    : Container(
                        height: 45,
                        alignment: Alignment.center,
                        child: Text("Save",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: isButtonEnable
                                ? Color(0xff01D35A)
                                : Colors.grey),
                      ),
              ))
        ],
      ),
    );
  }

  Widget afterSubmitCouponScreenView() {
    return Container(
      margin: EdgeInsets.all(20),
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text('Now you have',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    '#474747')),
                                fontSize: 25,
                                fontWeight: FontWeight.normal))),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.all(30),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(
                                CommonMethods.getColorHexFromStr('#DFDFDF')),
                            width: .5,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                child: Image.asset(
                                  consultationBgImage,
                                  height: 85,
                                  width: 85,
                                ),
                              ),
                              Container(
                                  height: 80,
                                  width: 80,
                                  margin: EdgeInsets.only(top: 20, bottom: 20),
                                  child: Image.asset(
                                    consultationImage,
                                    fit: BoxFit.contain,
                                  ))
                            ],
                          ),
                          Text('$consulCount Free Consultations',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      consulCount == 'No'
                                          ? '#DFDFDF'
                                          : '#474747')),
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal))
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 30, right: 30),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: .5,
                            color: Color(
                                CommonMethods.getColorHexFromStr('#DFDFDF')),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(top: 20, bottom: 20),
                              height: 80,
                              width: 80,
                              child: Image.asset(
                                testIcon,
                                fit: BoxFit.contain,
                              )),
                          Text('$testCount Free Diagnostic Test',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      testCount == 'No'
                                          ? '#DFDFDF'
                                          : '#474747')),
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: isSuccess
                    ? Container(
                        margin: EdgeInsets.only(bottom: 0, top: 30),
                        child: Text('Promo Code Applied!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    '#474747')),
                                fontSize: 15,
                                fontWeight: FontWeight.normal)),
                      )
                    : Container(),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.getAppBar(context, title, true),
      backgroundColor: Colors.white,
      body: isFetchingData
          ? Container(
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                backgroundColor: Colors.green,
              ),
            )
          : (showCouponScreen
              ? couponScreenView()
              : afterSubmitCouponScreenView()),
    );
  }

  Future saveCouponCode() async {
/*    setState(() {
      isProgressing = true;
    });
    var body = {"coupon": couponCodeController.text.trim()};
    PutCoupons result = await submitCoupon(body, user_token).catchError((error) {
      CommonMethods.showLongToast("Something went wrong!");
      isProgressing = false;
    });
    setState(() {
      isProgressing = false;
      if (result.success) {
        couponCodeController.text = '';
        showCouponScreen = false;
        isSuccess = true;
        showSuccessPopup();
      } else {
        isSuccess = false;
        showCouponScreen = true;
        CommonMethods.showInSnackBar(_scaffoldKey, result.message, Colors.red);
      }
    });*/
  }

  Future showSuccessPopup() async {
    confirmationDialog(context);
    await Future.delayed(Duration(seconds: 10), () async {
      setState(() {
        isSuccess = false;
        title = 'Availed Benefits';
        Navigator.pop(context);
      });
    });
  }

  confirmationDialog(BuildContext context) {
    return showGeneralDialog<bool>(
        barrierColor: Colors.black.withOpacity(0.3),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                  backgroundColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    height: MediaQuery.of(context).size.height / 2 + 20,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2 + 20,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage('assets/images/bgElephantPopup.png'),
                            fit: BoxFit.fill),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 30.0, top: 25),
                                child: Icon(Icons.close, color: Colors.grey),
                              ),
                              alignment: Alignment.topRight,
                            ),
                          ),
                          Container(
                            margin: new EdgeInsets.only(top: 0.0, bottom: 10),
                            child: new Text(
                              'YAY !',
                              style: TextStyle(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      '#FF7572')),
                                  fontSize: 26.0,
                                  fontFamily: 'helvetica_neue_light',
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Container(
                                child: Image.asset(
                              'assets/images/elephant_image.png',
                              fit: BoxFit.contain,
                            )),
                          ),
                          Container(
                            padding: new EdgeInsets.only(top: 10.0, bottom: 20),
                            child: new Text(
                              'BE IN THE PINK OF YOUR HEALTH',
                              style: TextStyle(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      '#8F8F8F')),
                                  fontSize: 14.0,
                                  fontFamily: 'helvetica_neue_light',
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                              padding: new EdgeInsets.only(bottom: 50),
                              child: new Text(
                                'Successfully Applied!',
                                style: TextStyle(
                                  color: Color(CommonMethods.getColorHexFromStr(
                                      '#8F8F8F')),
                                  fontSize: 16.0,
                                  fontFamily: 'helvetica_neue_light',
                                ),
                                textAlign: TextAlign.center,
                              ))
                        ],
                      ),
//                  ),
                    ),
                  )),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  Future getCouponsHistory() async {
    /*  couponsList = [];
    GetCouponsList result = await getCouponsListInfo(user_token).catchError((error) {
      CommonMethods.showLongToast("Something went wrong!");
      isFetchingData = false;
    });
    setState(() {
      isFetchingData = false;
    });
    if (result.info['coupons'].length > 0) {
      couponsList.add(result.info['coupons']);
    }
    setState(() {
      hasCoupons = couponsList.length > 0 ? true : false;
      showCouponScreen = hasCoupons ? false : true;
      if (hasCoupons) {
        title = 'Availed Benefits';
        for (var i = 0; i < couponsList.length; i++) {
          if (couponsList[0] != null) {
            couponName = couponsList[0][i]['coupon'] != null ? couponsList[0][i]['coupon'] : '';
            consulCount = couponsList[0][i]['consultations'] != null ? couponsList[0][i]['consultations'].toString() : '';
            testCount = couponsList[0][i]['tests'] != null ? couponsList[0][i]['tests'].toString() : '';
            if (consulCount == '0') {
              consultationImage = 'assets/images/shadow_consul_icon.png';
              consultationBgImage = 'assets/images/light_blue_bg.png';
            }
            if (testCount == '0')
              testIcon = 'assets/images/light_test_icon.png';
            consulCount = consulCount == '0'? 'No' : consulCount;
            testCount = testCount == '0'? 'No' : testCount;
          }
        }
      } else {
        consulCount = '2';
        testCount = '1';
      }
    });
    print('result$couponsList');*/
  }
}
