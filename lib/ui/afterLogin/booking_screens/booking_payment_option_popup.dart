import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PopupChoose extends StatefulWidget {
  final num bookInPrice;
  final String totalPrice;

  PopupChoose({this.bookInPrice, this.totalPrice});

  @override
  _PopupChooseState createState() => _PopupChooseState();
}

class _PopupChooseState extends State<PopupChoose> {
  bool _valueTwentyP, _valuePayFull, _payOnly;

  @override
  void initState() {
    if (widget.bookInPrice != null) {
      _payOnly = true;
      _valueTwentyP = false;
    } else {
      _valueTwentyP = true;
    }
    _valuePayFull = false;
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
            widget.bookInPrice == null
                ? Container()
                : Card(
                    elevation: 0,
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          print(_payOnly);
                          _payOnly = true;
                          _valueTwentyP = false;
                          _valuePayFull = false;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _payOnly
                              ? new Image.asset(
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
                              'Pay ${widget.bookInPrice}',
                              style: new TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            SizedBox(
              height: 15,
            ),
            Card(
              elevation: 0,
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (widget.bookInPrice != null) {
                      _payOnly = false;
                    }
                    _valueTwentyP = true;
                    _valuePayFull = false;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _valueTwentyP
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
                        child: new Text('Pay 20%',
                            style: new TextStyle(fontSize: 16.0))),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Card(
              elevation: 0,
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (widget.bookInPrice != null) {
                      _payOnly = false;
                    }
                    _valueTwentyP = false;
                    _valuePayFull = true;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _valuePayFull
                        ? new Image.asset(
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
                      child: new Text(
                        'Pay full. No Hassle!',
                        style: new TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                if (widget.bookInPrice != null && _payOnly) {
                  num totalPrice = num.tryParse(widget.totalPrice);
                  var percentage = ((widget.bookInPrice * 100) / totalPrice)
                          .floorToDouble() ??
                      0;
                  print("percentage$percentage");
                  Navigator.of(context).pop("$percentage");
                } else if (_valueTwentyP) {
                  Navigator.of(context).pop("20");
                } else {
                  Navigator.of(context).pop("100");
                }
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
