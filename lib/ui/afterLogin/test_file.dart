import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upi_pay/upi_pay.dart';

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  String _upiAddrError, _amountError;

  final _upiAddressController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isUpiEditable = false;
  Future<List<ApplicationMeta>> _appsFuture;

  @override
  void initState() {
    super.initState();
    _amountController.text = "1";
    _upiAddressController.text = "9816199453@okbizaxis";
    _appsFuture = UpiPay.getInstalledUpiApplications();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiAddressController.dispose();
    super.dispose();
  }

  Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress(_upiAddressController.text);
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });
    if (_amountController.text == null ||
        _amountController.text.trim().isEmpty) {
      setState(() {
        _amountError = "Please enter valid amount";
      });
      return;
    }
    setState(() {
      _amountError = null;
    });
    _amountError = null;
    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");

    final a = await UpiPay.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      transactionNote: "Consultation fee",
      receiverName: 'Plunes',
      receiverUpiAddress: _upiAddressController.text,
      transactionRef: transactionRef,
      merchantCode: '7372',
    );

    print(a);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 32),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      controller: _upiAddressController,
                      enabled: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'address@upi',
                        labelText: 'Receiving UPI Address',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (_upiAddrError != null)
                ? Container(
                    margin: EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      _upiAddrError,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Container(),
            Container(
              margin: EdgeInsets.only(top: 32),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      readOnly: false,
                      enabled: true,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Amount',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (_amountError != null)
                ? Container(
                    margin: EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      _amountError,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : Container(),
            Container(
              margin: EdgeInsets.only(top: 128, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Pay Using',
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  FutureBuilder<List<ApplicationMeta>>(
                    future: _appsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Container();
                      }
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.6,
                        physics: NeverScrollableScrollPhysics(),
                        children: snapshot.data
                            .map((it) => Material(
                                  key: ObjectKey(it.upiApplication),
                                  color: Colors.grey[200],
                                  child: InkWell(
                                    onTap: () => _onTap(it),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.memory(
                                          it.icon,
                                          width: 64,
                                          height: 64,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 4),
                                          child: Text(
                                            it.upiApplication.getAppName(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

String _validateUpiAddress(String value) {
  if (value.isEmpty) {
    return 'UPI Address is required.';
  }

  if (!UpiPay.checkIfUpiAddressIsValid(value)) {
    return 'UPI Address is invalid.';
  }

  return null;
}
