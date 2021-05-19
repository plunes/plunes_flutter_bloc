import 'package:flutter/material.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';

// ignore: must_be_immutable
class BookConsultationScreen extends BaseActivity {
  @override
  _TestBookingScreenState createState() => _TestBookingScreenState();
}

class _TestBookingScreenState extends BaseState<BookConsultationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: widget.getAppBar(context, "Book Consultation", true),
        body: _getBodyWidget());
  }

  Widget _getBodyWidget() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return CommonWidgets().getConsultationWidget(index);
      },
      itemCount: 5,
    );
  }
}
