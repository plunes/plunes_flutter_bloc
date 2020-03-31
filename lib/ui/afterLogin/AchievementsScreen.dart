import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/ImagePicker/ImagePickerHandler.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/resources/interface/DialogCallBack.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsScreen extends BaseActivity {
  static const tag = '/achievemntsscreen';

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin, ImagePickerListener
    implements DialogCallBack {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth, backAssetImage, counter = 0, selectedIndex;
  List selectedImageList = new List();
  final _textController = TextEditingController();
  AnimationController _animationController;
  ImagePickerHandler imagePicker;
  ScrollController _controller;
  bool progress = false;
  String user_token = "";
  String user_id = "";
  File _image;

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    user_token = token;
    user_id = uid;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.getAppBar(context, plunesStrings.achievement, true),
      key: _scaffoldKey,
      body: GestureDetector(
          onTap: () => CommonMethods.hideSoftKeyboard(), child: bodyView()),
    );
  }

  Widget bodyView() {
    return Container(
      child: ListView(
        children: <Widget>[
          getShareAchievementBoxView(),
          Container(
            margin: EdgeInsets.only(top: 10, left: 20, right: 20),
            child: widget.createTextViews('$counter/250', 16,
                colorsFile.lightGrey2, TextAlign.right, FontWeight.normal),
          ),
          widget.getSpacer(0.0, 20.0),
          getBackFilterView(),
          widget.getSpacer(0.0, 30.0),
          getImageFetcherView(),
          Container(
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: progress
                  ? SpinKitThreeBounce(
                      color: Color(hexColorCode.defaultGreen), size: 30.0)
                  : widget.getDefaultButton(
                      plunesStrings.add, globalWidth - 100, 42, addAchievement)),
        ],
      ),
    );
  }

  Widget getShareAchievementBoxView() {
    return Container(
      width: globalWidth,
      height: 200,
      margin: EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Center(
            child: createTextField(_textController, context,
                TextInputType.multiline, plunesStrings.shareYourAchievement)),
      ),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(backAssetImage), fit: BoxFit.cover),
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(10))),
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
          onChanged: (text) {
            setState(() {
              counter = text.length;
            });
          },
          cursorColor: backAssetImage == assetsImageFile.whiteImage
              ? Color(CommonMethods.getColorHexFromStr(colorsFile.black))
              : Color(CommonMethods.getColorHexFromStr(colorsFile.white)),
          style: TextStyle(
              height: 1.5,
              fontSize: 18.0,
              letterSpacing: 1.1,
              color: backAssetImage == assetsImageFile.whiteImage
                  ? Color(CommonMethods.getColorHexFromStr(colorsFile.black0))
                  : Color(CommonMethods.getColorHexFromStr(colorsFile.white))),
          decoration: InputDecoration(
            hintStyle: TextStyle(
                color: backAssetImage == assetsImageFile.whiteImage
                    ? Color(
                        CommonMethods.getColorHexFromStr(colorsFile.lightGrey2))
                    : Color(
                        CommonMethods.getColorHexFromStr(colorsFile.white))),
            hintText: hintText,
            border: InputBorder.none,
            counterText: '',
          ),
          /*  decoration: inputDecorationWithoutError(hintText)*/
        ));
  }

  void addAchievement() {}

  Widget getBackFilterView() {
    return Container(
        height: 50,
        padding: EdgeInsets.only(left: 20),
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: assetsImageFile.gradientImageArray.length,
            itemBuilder: (context, index) {
              return getItemRowView(index);
            }));
  }

  Widget getItemRowView(int index) {
    return Container(
        width: 50,
        height: 50,
        margin: EdgeInsets.only(right: 10),
        child: InkWell(
          onTap: () {
            setState(() {
              backAssetImage = assetsImageFile.gradientImageArray[index];
            });
          },
          child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage(assetsImageFile.gradientImageArray[index]),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ))),
        ));
  }

  Widget getImageFetcherView() {
    return Container(
        height: 120,
        padding: EdgeInsets.only(left: 20),
        child: ListView.builder(
            controller: _controller,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: selectedImageList.length + 1,
            itemBuilder: (context, index) {
              return index == selectedImageList.length
                  ? getImageViewItem(index)
                  : getAddedImageView(index);
            }));
  }

  Widget getImageViewItem(index) {
    return InkWell(
      onTap: () {
        imagePicker.showDialog(context);
      },
      child: Container(
        margin: EdgeInsets.only(left: 5, top: 8, bottom: 12, right: 10),
        width: 120,
        height: 100,
        child: Center(
          child: widget.getAssetIconWidget(
              assetsImageFile.plusIcon, 50, 50, BoxFit.cover),
        ),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }

  Widget getAddedImageView(int index) {
    return Container(
      width: 130,
      height: 100,
      child: Stack(
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(top: 3),
              child: Card(
                  elevation: 3,
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: widget.getAssetIconWidget(
                      selectedImageList[index], 100, 120, BoxFit.cover))),
          Align(
              alignment: FractionalOffset.topRight,
              child: InkWell(
                onTap: () {
                  selectedIndex = index;
                  CommonMethods.confirmationDialog(
                      context, plunesStrings.removeImageMsg, this);
                },
                child: widget.getCrossButton(),
              )),
        ],
      ),
    );
  }

  @override
  dialogCallBackFunction(String action) {
    if (action == 'DONE') {
      selectedImageList.removeAt(selectedIndex);
      setState(() {});
    }
  }

  @override
  fetchImageCallBack(File _image) {
    if (_image != null) {
      print("image==" + base64Encode(_image.readAsBytesSync()).toString());
      this._image = _image;
      selectedImageList.add(_image.path);
      _controller.animateTo(_controller.offset + 150.0,
          duration: Duration(microseconds: 100), curve: Curves.ease);
    }
  }

  void initializeForImageFetching() {
    _animationController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        print("===called");
      });
    imagePicker = new ImagePickerHandler(this, _animationController, false);
    imagePicker.init();
  }

  void initialize() {
    _controller = ScrollController();
    backAssetImage = assetsImageFile.whiteImage;
    getSharedPreferences();
    initializeForImageFetching();
  }
}
