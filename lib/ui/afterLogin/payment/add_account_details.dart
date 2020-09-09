import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/payment_bloc/payment_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class AddBankDetails extends BaseActivity {
  static const tag = '/addbankdetails';

  @override
  _AddBankDetailsState createState() => _AddBankDetailsState();
}

class _AddBankDetailsState extends BaseState<AddBankDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isValidName = true;
  bool isValidAccountNum = true;
  bool isValidIfscCode = true;
  bool isValidPanNum = true;
  bool validAccountHolderName = true;

  TextEditingController bankNameController = new TextEditingController();
  TextEditingController accountNumberController = new TextEditingController();
  TextEditingController ifscCodeController = new TextEditingController();
  TextEditingController panNumberController = new TextEditingController();
  TextEditingController accountHolderNameController =
      new TextEditingController();
  bool progress = true;
  ManagePaymentBloc _managePaymentBloc;

  @override
  void dispose() {
    bankNameController?.dispose();
    accountNumberController?.dispose();
    ifscCodeController?.dispose();
    panNumberController?.dispose();
    accountHolderNameController?.dispose();
    _managePaymentBloc?.dispose();
    super.dispose();
  }

  void _setDetails() async {
    progress = true;
    _setState();
    var details = BankDetails(
        accountHolderName: accountHolderNameController.text.trim(),
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        ifscCode: ifscCodeController.text.trim(),
        panNumber: panNumberController.text.trim());
    var result =
        await _managePaymentBloc.setBankDetails(User(bankDetails: details));
    progress = false;
    _setState();
    if (result is RequestSuccess) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _successPopup(context),
      );
    } else if (result is RequestFailed) {
      widget.showInSnackBar(
          result.failureCause, PlunesColors.BLACKCOLOR, _scaffoldKey);
    }
  }

  @override
  void initState() {
    progress = true;
    _managePaymentBloc = ManagePaymentBloc();
    _getBankDetails();
    super.initState();
  }

  _getBankDetails() async {
    var result = await _managePaymentBloc.getBankDetails();
    progress = false;
    _setState();
    if (result is RequestSuccess) {
      BankDetails bankDetails = result.response;
      if (bankDetails != null) {
        accountNumberController.clear();
        ifscCodeController.clear();
        panNumberController.clear();
        bankNameController.clear();
        accountHolderNameController.clear();
        accountHolderNameController.text = bankDetails.accountHolderName;
        accountNumberController.text = bankDetails.accountNumber ?? "";
        ifscCodeController.text = bankDetails.ifscCode ?? "";
        panNumberController.text = bankDetails.panNumber ?? "";
        bankNameController.text = bankDetails.bankName ?? "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bank_name = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {
            if (val == '') {
              isValidName = false;
            } else {
              isValidName = true;
            }
          });
        },
        controller: bankNameController,
        decoration: InputDecoration(
            labelText: 'Bank Name',
            errorText: isValidName ? null : "Please enter your bank name"),
      ),
    );

    final account_number = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
        onChanged: (val) {
          setState(() {
            if (val.trim().isEmpty) {
              isValidAccountNum = false;
            } else {
              isValidAccountNum = true;
            }
          });
        },
        controller: accountNumberController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            labelText: 'Account Number',
            errorText:
                isValidAccountNum ? null : "Please enter your Account Number"),
      ),
    );

    final IFSC_code = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {
            if (val == '') {
              isValidIfscCode = false;
            } else {
              isValidIfscCode = true;
            }
          });
        },
        controller: ifscCodeController,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
            labelText: 'IFSC Code',
            errorText: isValidIfscCode ? null : "Please enter your IFSC Code"),
      ),
    );

    final pan_number = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {
            String regexp = r'^([A-Z]){5}([0-9]){4}([A-Z]){1}?$';
            if (val == '' || !RegExp(regexp).hasMatch(val)) {
              isValidPanNum = false;
            } else {
              isValidPanNum = true;
            }
          });
        },
        controller: panNumberController,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
            labelText: 'Pan Number',
            errorText: isValidPanNum ? null : "Please enter your Pan Number"),
      ),
    );

    final Account_holder_name = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        onChanged: (val) {
          setState(() {
            if (val == '') {
              validAccountHolderName = false;
            } else {
              validAccountHolderName = true;
            }
          });
        },
        controller: accountHolderNameController,
        decoration: InputDecoration(
            labelText: "Account Holder\'s Name",
            errorText: validAccountHolderName
                ? null
                : "Please enter Account Holder\'s Name"),
      ),
    );

    final proceed = Padding(
      padding:
          const EdgeInsets.only(left: 36.0, right: 36.0, bottom: 30, top: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: InkWell(
          onTap: () {
            if (isValidName &&
                isValidAccountNum &&
                isValidIfscCode &&
                isValidPanNum &&
                validAccountHolderName &&
                bankNameController.text != '' &&
                accountNumberController.text != '' &&
                ifscCodeController.text != '' &&
                panNumberController.text != '' &&
                accountHolderNameController.text != '') {
              _hideKeyboard();
              _setDetails();
            }
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: isValidName &&
                        isValidAccountNum &&
                        isValidIfscCode &&
                        isValidPanNum &&
                        validAccountHolderName &&
                        bankNameController.text != '' &&
                        accountNumberController.text != '' &&
                        ifscCodeController.text != '' &&
                        panNumberController.text != '' &&
                        accountHolderNameController.text != ''
                    ? Color(0xff01d35a)
                    : Colors.grey),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Proceed', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );

    final form = Container(
      child: ListView(
        children: <Widget>[
          bank_name,
          SizedBox(
            height: 10,
          ),
          account_number,
          SizedBox(
            height: 10,
          ),
          IFSC_code,
          SizedBox(
            height: 10,
          ),
          pan_number,
          SizedBox(
            height: 10,
          ),
          Account_holder_name,
          SizedBox(
            height: 20,
          ),
          progress ? CustomWidgets().getProgressIndicator() : proceed
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        _hideKeyboard();
        return true;
      },
      child: Scaffold(
          appBar: widget.getAppBar(context, PlunesStrings.bankDetails, true,
              func: () => _hideKeyboard()),
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body: form),
    );
  }

  Widget _successPopup(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Saved..'),
      actions: <Widget>[CustomWidgets().getSingleCommonButton(context, "Ok")],
    );
  }

  _hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _setState() {
    if (mounted) setState(() {});
  }
}
