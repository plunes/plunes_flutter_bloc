import 'package:flutter/material.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/payment/add_account_details.dart';

// ignore: must_be_immutable
class ManagePayments extends BaseActivity {
  static const tag = '/manage_payment';

  @override
  _ManagePaymentsState createState() => _ManagePaymentsState();
}

// class _ManagePaymentsState extends BaseState<ManagePayments> {
class _ManagePaymentsState extends State<ManagePayments> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        key: scaffoldKey,
        appBar: widget.getAppBar(context, plunesStrings.managePayment, true) as PreferredSizeWidget?,
        body: Container(
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddBankDetails()));
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset(
                          'assets/payments2.png',
                          height: 25,
                          width: 25,
                        ),
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Add/Edit Bank Details"),
                          Text(
                            "Wallet Account Settings",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          )
                        ],
                      )),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: Color(0xffbdbdbd),
                height: 0.3,
              ),
            ],
          ),
        ));
  }
}
