import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';

// ignore: must_be_immutable
class BookTestScreen extends BaseActivity {
  @override
  _TestBookingScreenState createState() => _TestBookingScreenState();
}

class _TestBookingScreenState extends BaseState<BookTestScreen> {
  TextEditingController _textController;

  _onTextClear() {}

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          key: scaffoldKey,
          appBar: widget.getAppBar(context, "Book Test", true),
          body: _getBodyWidget()),
    );
  }

  Widget _getBodyWidget() {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                vertical: AppConfig.verticalBlockSize * 1.5, horizontal: 20),
            child: CommonWidgets().getSearchBarForTestConsProcedureScreens(
                _textController, "Search test", () => _onTextClear()),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return CommonWidgets().getBookTestWidget(index);
              },
              itemCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
