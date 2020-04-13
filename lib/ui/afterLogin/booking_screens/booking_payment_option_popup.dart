import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';

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
    print("_paymentSelectionOptions${_paymentSelectionOptions.toString()}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Container(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Align(
              child: Icon(Icons.clear),
              alignment: Alignment.topRight,
            ),
          ),
        ),
      ),
      content: Container(
        child: Column(
          children: <Widget>[
            Text(
              "Now you can have multiple\n"
              "telephonic consultations & one free visit!",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: AppConfig.verticalBlockSize * 15,
              width: double.infinity,
              child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (context, count) {
                  return Card(
                    elevation: 0,
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 3),
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
                                  'assets/images/bid/check.png',
                                  height: 20,
                                  width: 20,
                                )
                              : Image.asset(
                                  'assets/images/bid/uncheck.png',
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
                                      ? 'Book in ${_paymentSelectionOptions[count].paymentUnit}'
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
            GestureDetector(
              onTap: () {
//                  Navigator.of(context).pop("100");
              },
              child: Container(
                height: 35,
                width: double.infinity,
                margin: EdgeInsets.only(left: 5, right: 5),
                alignment: Alignment.center,
                child: Text(
                  "Continue",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
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
