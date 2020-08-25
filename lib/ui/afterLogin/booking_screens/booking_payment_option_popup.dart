import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

class PopupChoose extends StatefulWidget {
  final num bookInPrice;
  final String totalPrice;
  final Services services;

  PopupChoose({this.bookInPrice, this.totalPrice, this.services});

  @override
  _PopupChooseState createState() => _PopupChooseState();
}

class _PopupChooseState extends State<PopupChoose> {
  List<PaymentSelector> _paymentSelectionOptions;

  @override
  void initState() {
    _paymentSelectionOptions = [];
    if (widget.bookInPrice != null) {
      _paymentSelectionOptions.add(PaymentSelector(
          isInPercent: false,
          isSelected: true,
          paymentUnit: "${widget.bookInPrice}"));
      widget.services.paymentOptions.forEach((option) {
        _paymentSelectionOptions.add(PaymentSelector(
            isInPercent: true,
            isSelected: false,
            paymentUnit: "${option.toString()}"));
      });
    } else {
      for (int pIndex = 0;
          pIndex < widget.services.paymentOptions.length;
          pIndex++) {
        _paymentSelectionOptions.add(PaymentSelector(
            isInPercent: true,
            isSelected: pIndex == 0 ? true : false,
            paymentUnit:
                "${widget.services.paymentOptions[pIndex].toString()}"));
      }
    }
//    print("_paymentSelectionOptions${_paymentSelectionOptions.toString()}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
//      title: Container(
//        child: GestureDetector(
//          onTap: () {
//            Navigator.pop(context);
//          },
//          child: Padding(
//            padding: const EdgeInsets.only(left: 8),
//            child: Align(
//              child: Icon(Icons.clear),
//              alignment: Alignment.topRight,
//            ),
//          ),
//        ),
//      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 4,
                  horizontal: AppConfig.horizontalBlockSize * 4),
              child: Text(
                "Now you can have multiple\n"
                "telephonic consultations & one free visit!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
//            SizedBox(
//              height: 20,
//            ),
            Container(
              margin: EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
              height: AppConfig.verticalBlockSize * 15,
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, count) {
                  return Card(
                    elevation: 0,
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 2),
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _paymentSelectionOptions.forEach((paymentOption) {
                            paymentOption.isSelected = false;
                          });
                          _paymentSelectionOptions[count].isSelected = true;
                        });
                      },
                      onDoubleTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _paymentSelectionOptions[count].isSelected
                              ? Image.asset(
                                  plunesImages.checkIcon,
                                  height: 20,
                                  width: 20,
                                )
                              : Image.asset(
                                  plunesImages.unCheckIcon,
                                  height: 20,
                                  width: 20,
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                              width: 150,
                              child: Text(
                                  (widget.bookInPrice != null && count == 0)
                                      ? '${PlunesStrings.bookIn} ${_paymentSelectionOptions[count].paymentUnit}'
                                      : count !=
                                              _paymentSelectionOptions.length -
                                                  1
                                          ? 'Pay ${_paymentSelectionOptions[count].paymentUnit}%'
                                          : 'Pay full. No Hassle',
                                  style: TextStyle(fontSize: 16.0))),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: _paymentSelectionOptions.length ?? 0,
              ),
            ),

            Container(
              height: 0.5,
              width: double.infinity,
              color: PlunesColors.GREYCOLOR,
//              margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
            ),
            Container(
              height: AppConfig.verticalBlockSize * 6,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                        splashColor: Colors.redAccent.withOpacity(.2),
                        highlightColor: Colors.redAccent.withOpacity(.2),
                        focusColor: Colors.redAccent.withOpacity(.2),
                        onPressed: () {
                          Navigator.pop(context);
                          return;
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 1.5,
//                                horizontal: AppConfig.horizontalBlockSize * 4
                            ),
                            child: Text(
                              'Back',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                  color: Colors.redAccent),
                            ))),
                  ),
                  Container(
                    height: AppConfig.verticalBlockSize * 6,
                    color: PlunesColors.GREYCOLOR,
                    width: 0.5,
                  ),
                  Expanded(
//                                      flex: 200,
                    child: FlatButton(
                        focusColor: PlunesColors.SPARKLINGGREEN.withOpacity(.2),
                        splashColor:
                            PlunesColors.SPARKLINGGREEN.withOpacity(.2),
                        highlightColor:
                            PlunesColors.SPARKLINGGREEN.withOpacity(.2),
                        onPressed: () {
                          PaymentSelector _paymentSelector;
                          if (_paymentSelectionOptions != null &&
                              _paymentSelectionOptions.isNotEmpty) {
                            _paymentSelectionOptions.forEach((paymentObj) {
                              if (paymentObj.isSelected) {
                                _paymentSelector = paymentObj;
                              }
                            });
                          }
                          Navigator.of(context).pop(_paymentSelector);
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: AppConfig.verticalBlockSize * 1.5,
//                                horizontal: AppConfig.horizontalBlockSize * 4
                            ),
                            child: Text(
                              'Continue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: AppConfig.mediumFont,
                                  color: PlunesColors.SPARKLINGGREEN),
                            ))),
                  ),
                ],
              ),
            ),
//            GestureDetector(
//                onTap: () {
//                  PaymentSelector _paymentSelector;
//                  if (_paymentSelectionOptions != null &&
//                      _paymentSelectionOptions.isNotEmpty) {
//                    _paymentSelectionOptions.forEach((paymentObj) {
//                      if (paymentObj.isSelected) {
//                        _paymentSelector = paymentObj;
//                      }
//                    });
//                  }
//                  Navigator.of(context).pop(_paymentSelector);
//                },
//                child: Container(
//                  margin: EdgeInsets.only(
//                      left: AppConfig.horizontalBlockSize * 15,
//                      right: AppConfig.horizontalBlockSize * 15),
//                  decoration: BoxDecoration(
//                      borderRadius: BorderRadius.all(Radius.circular(5))),
//                  child: CustomWidgets().getRoundedButton(
//                      "Continue",
//                      AppConfig.horizontalBlockSize * 8,
//                      PlunesColors.GREENCOLOR,
//                      AppConfig.horizontalBlockSize * 0,
//                      AppConfig.verticalBlockSize * 1.2,
//                      PlunesColors.WHITECOLOR),
//                )),
//            SizedBox(
//              height: 5,
//            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSelector {
  String paymentUnit;

  @override
  String toString() {
    return 'PaymentSelector{paymentUnit: $paymentUnit, isSelected: $isSelected, isInPercent: $isInPercent}';
  }

  bool isSelected;
  bool isInPercent;

  PaymentSelector({this.isSelected, this.paymentUnit, this.isInPercent});
}
