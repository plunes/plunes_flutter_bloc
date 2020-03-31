import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/GalleryScreen.dart';

import 'SelectSpecialization.dart';

class UploadPrescriptionDialog extends BaseActivity {
  final String imageUrl;

  UploadPrescriptionDialog({Key key, this.imageUrl}) : super(key: key);

  @override
  _UploadPrescriptionDialogState createState() =>
      _UploadPrescriptionDialogState();
}

class _UploadPrescriptionDialogState extends State<UploadPrescriptionDialog> {
  List<dynamic> _selectedItemId = List(), _selectedSpecializationData = List();
  final specializationController = TextEditingController();
  final reportNameController = new TextEditingController();
  final notesController = new TextEditingController();
  final notesFocus = new FocusNode();
  final reportsNameFocus = new FocusNode();
  var globalHeight, globalWidth;
  bool progress = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    specializationController.dispose();
    super.dispose();
  }

  getSpecializationData() {
    showDialog(
        context: context,
        builder: (BuildContext context) => SelectSpecialization(
            spec: CommonMethods.catalogueLists,
            from: null,
            selectedItemId: _selectedItemId,
            selectedItemData: _selectedSpecializationData)).then((val) {
      if (val != '' && val != null) {
        _selectedItemId = val['SelectedId'];
        specializationController.text = val['SelectedData']
            .toString()
            .replaceAll('[', '')
            .replaceAll(']', '');
      }
    });
  }

  Widget getAddedImageView() {
    return Container(
        height: 280,
        child: InkWell(
          onTap: () {
            widget.showPhoto(context,
                Photo(assetName: widget.imageUrl, title: '', caption: ''));
          },
          child: Card(
              elevation: 5,
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: widget.getAssetImageWidget(widget.imageUrl)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Card(
        elevation: 0.0,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: EdgeInsets.all(5.0),
          color: Colors.white,
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              getAddedImageView(),
              Container(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  children: <Widget>[
                    widget.getSpacer(0.0, 20.0),
                    createTextField(
                        specializationController,
                        '${plunesStrings.chooseSpeciality}',
                        TextInputType.text,
                        TextCapitalization.words,
                        true,
                        plunesStrings.errorMsgEnterSpecialization),
                    widget.getSpacer(0.0, 20.0),
                    createTextField(
                        reportNameController,
                        '${plunesStrings.reportName}',
                        TextInputType.text,
                        TextCapitalization.words,
                        true,
                        ''),
                    widget.getSpacer(0.0, 20.0),
                    createTextField(notesController, '${plunesStrings.addNotes}',
                        TextInputType.text, TextCapitalization.words, true, ''),
                    widget.getSpacer(0.0, 20.0),
                    getButton(),
                    widget.getSpacer(0.0, 10.0),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget createTextField(
      TextEditingController controller,
      String placeHolder,
      TextInputType inputType,
      TextCapitalization textCapitalization,
      bool fieldFlag,
      String errorMsg) {
    return InkWell(
      onTap: () {
        if (controller == specializationController) getSpecializationData();
      },
      child: Container(
          padding: EdgeInsets.zero,
          width: MediaQuery.of(context).size.width,
          child: TextField(
              textCapitalization: textCapitalization,
              keyboardType: inputType,
              textInputAction: controller == notesController
                  ? TextInputAction.done
                  : TextInputAction.next,
              onSubmitted: (String value) {
                setFocus(controller).unfocus();
                FocusScope.of(context).requestFocus(setTargetFocus(controller));
              },
              controller: controller,
              cursorColor: Color(
                  CommonMethods.getColorHexFromStr(colorsFile.defaultGreen)),
              focusNode: setFocus(controller),
              enabled: controller == specializationController ? false : true,
              style: TextStyle(
                fontSize: 15.0,
              ),
              decoration: widget.myInputBoxDecoration(
                  colorsFile.defaultGreen,
                  colorsFile.lightGrey1,
                  placeHolder,
                  errorMsg,
                  fieldFlag,
                  controller,
                  null))),
    );
  }

  FocusNode setFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == reportNameController) {
      focusNode = reportsNameFocus;
    } else if (controller == notesController) {
      focusNode = notesFocus;
    }
    return focusNode;
  }

  FocusNode setTargetFocus(TextEditingController controller) {
    FocusNode focusNode;
    if (controller == reportNameController) {
      focusNode = notesFocus;
    } else if (controller == notesController) {
      focusNode = null;
    }
    return focusNode;
  }

  Widget getButton() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(right: 5),
                  child: widget.getBorderButton(
                      plunesStrings.cancel, globalWidth, onBackPressed))),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(left: 5),
            child: progress
                ? SpinKitThreeBounce(
                    color: Color(hexColorCode.defaultGreen), size: 30.0)
                : widget.getDefaultButton(
                    plunesStrings.upload, globalWidth, 42, upload),
          ))
        ],
      ),
    );
  }

  onBackPressed() {
    Navigator.pop(context);
  }

  upload() {
    Navigator.pop(context);
  }
}
