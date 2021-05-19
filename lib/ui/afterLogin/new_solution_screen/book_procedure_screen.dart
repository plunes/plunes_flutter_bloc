import 'package:flutter/material.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';

// ignore: must_be_immutable
class BookProcedureScreen extends BaseActivity {
  @override
  _TestBookingScreenState createState() => _TestBookingScreenState();
}

class _TestBookingScreenState extends BaseState<BookProcedureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: widget.getAppBar(context, "Book Procedure", true),
        body: _getBodyWidget());
  }

  Widget _getBodyWidget() {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return CommonWidgets().getBookProcedureWidget(index);
        },
        itemCount: 5,
      ),
    );
  }
}
