import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/new_solution_model/insurance_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';

// ignore: must_be_immutable
class ShowInsuranceListScreen extends BaseActivity {
  final String? profId;
  final bool? shouldShowAppBar;
  Function? func;

  ShowInsuranceListScreen({this.profId, this.shouldShowAppBar, this.func});

  @override
  _ShowInsuranceListScreenState createState() =>
      _ShowInsuranceListScreenState();
}

class _ShowInsuranceListScreenState extends State<ShowInsuranceListScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  UserBloc? _userBloc;
  InsuranceModel? _insuranceModel;
  List<InsuranceProvider>? _searchedItemList;
  TextEditingController? _policySearchController;
  String? _failureCause;
  double? _wholeWidgetHeight;

  @override
  void initState() {
    _userBloc = UserBloc();
    _policySearchController = TextEditingController();
    _getInsuranceList();
    super.initState();
  }

  @override
  void dispose() {
    _policySearchController?.dispose();
    _userBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: (widget.shouldShowAppBar != null && !widget.shouldShowAppBar!)
            ? _wholeWidgetHeight ?? AppConfig.verticalBlockSize * 45
            : null,
        child: SafeArea(
          child: Scaffold(
            key: scaffoldKey,
            appBar: widget.shouldShowAppBar ?? true
                ? widget.getAppBar(context, "Check your insurance provider", true) as PreferredSizeWidget?
                : null,
            body: StreamBuilder<RequestState?>(
                stream: _userBloc!.insuranceStream,
                initialData:
                    (_insuranceModel == null) ? RequestInProgress() : null,
                builder: (context, snapshot) {
                  if (snapshot.data is RequestSuccess) {
                    RequestSuccess successObject = snapshot.data as RequestSuccess;
                    _insuranceModel = successObject.response;
                    _userBloc?.addStateInInsuranceListStream(null);
                  } else if (snapshot.data is RequestFailed) {
                    RequestFailed? _failedObj = snapshot.data as RequestFailed?;
                    _failureCause = _failedObj?.failureCause;
                    _userBloc?.addStateInInsuranceListStream(null);
                  } else if (snapshot.data is RequestInProgress) {
                    return Container(
                        child: CustomWidgets().getProgressIndicator());
                  }
                  if ((widget.shouldShowAppBar != null &&
                          !widget.shouldShowAppBar!) &&
                      (_insuranceModel == null ||
                          (_insuranceModel!.success != null &&
                              !_insuranceModel!.success!) ||
                          _insuranceModel!.data == null ||
                          _insuranceModel!.data == null ||
                          _insuranceModel!.data!.isEmpty) &&
                      _wholeWidgetHeight == null) {
                    _wholeWidgetHeight = 0.0;
                    Future.delayed(Duration(milliseconds: 20)).then((value) {
                      _setState();
                    });
                  }
                  return (_insuranceModel == null ||
                          (_insuranceModel!.success != null &&
                              !_insuranceModel!.success!) ||
                          _insuranceModel!.data == null ||
                          _insuranceModel!.data == null ||
                          _insuranceModel!.data!.isEmpty)
                      ? (widget.shouldShowAppBar != null &&
                              !widget.shouldShowAppBar!)
                          ? Container()
                          : Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 3),
                              child: CustomWidgets().errorWidget(
                                  _failureCause ??
                                      "Currently insurance facility not available",
                                  onTap: () => _getInsuranceList(),
                                  isSizeLess: true))
                      : _getBody();
                }),
          ),
          top: false,
          bottom: false,
        ),
      ),
    );
  }

  Widget _getBody() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 3,
          vertical: widget.shouldShowAppBar??true ? AppConfig.verticalBlockSize * 1.5
              : AppConfig.verticalBlockSize *  .01),
      child: Column(
        children: [
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 3.5),
          //   child: Text(
          //     "Check your insurance provider",
          //     style: TextStyle(fontSize: 20, color: PlunesColors.BLACKCOLOR),
          //   ),
          //   alignment: Alignment.topLeft,
          // ),
          Container(
            margin: EdgeInsets.only(top: widget.shouldShowAppBar??true ?
            AppConfig.verticalBlockSize * 1.4 :
            AppConfig.verticalBlockSize * .6
            ),
          ),
          (widget.shouldShowAppBar != null && !widget.shouldShowAppBar!)
              ? Container()
              : _getSearchBar(),
          Expanded(child: _getInsuranceListWidget())
        ],
      ),
    );
  }

  Widget _getSearchBar() {
    return Column(
      children: [
        Card(
          color: Color(CommonMethods.getColorHexFromStr("#FAFAFA")),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                  color: Color(CommonMethods.getColorHexFromStr("#DDDDDD")),
                  width: 1)),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                    child: TextField(
                  controller: _policySearchController,
                  onChanged: (text) {
                    if (text != null &&
                        text.trim().isNotEmpty &&
                        _insuranceModel != null &&
                        _insuranceModel!.data != null &&
                        _insuranceModel!.data!.isNotEmpty) {
                      _searchedItemList = [];
                      _insuranceModel!.data!.forEach((element) {
                        if (element.insurancePartner != null &&
                            element.insurancePartner!.trim().isNotEmpty &&
                            element.insurancePartner!
                                .toLowerCase()
                                .contains(text.trim().toLowerCase())) {
                          _searchedItemList!.add(element);
                        }
                      });
                      _setState();
                    } else if (text == null || text.trim().isEmpty) {
                      _searchedItemList = [];
                      _setState();
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(right: 8, left: 6),
                      child: const Icon(
                        Icons.search,
                        color: PlunesColors.BLACKCOLOR,
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(),
                    hintText: "Search your insurance provider",
                    isDense: false,

                    hintStyle: TextStyle(
                        // fontSize: 12,
                        color:
                            Color(CommonMethods.getColorHexFromStr("#333333"))),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _getInsuranceList() {
    _userBloc!.getInsuranceList(widget.profId);
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getInsuranceListWidget() {
    List<InsuranceProvider> _list = [];
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 3.5),
            constraints: BoxConstraints(
              maxHeight: AppConfig.verticalBlockSize * 35,
              minHeight: AppConfig.verticalBlockSize * 0.5,
            ),
            child: _getILISTWidget(_getListItems(_list)),
          ),
        ),
        (widget.func != null &&
                _getListItems(_list) != null &&
                _getListItems(_list)!.length > 10)
            ? Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onDoubleTap: () {},
                  onTap: () {
                    widget.func!();
                    return;
                  },
                  focusColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "View More",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#25B281"))),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 3),
                          child: Icon(Icons.keyboard_arrow_down,
                              size: 18,
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#25B281"))),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  ScrollController _scrollController = ScrollController();

  Widget _getILISTWidget(List<InsuranceProvider>? list) {
    return Scrollbar(
      controller: _scrollController,
      isAlwaysShown:
          (widget.shouldShowAppBar != null && !widget.shouldShowAppBar!)
              ? false
              : true,
      child: ListView.builder(
        shrinkWrap: true,
        controller: _scrollController,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0),
            child: Row(
              children: [
                Icon(Icons.add_circle,
                    size: 8.5,
                    color: Color(CommonMethods.getColorHexFromStr("#25B281"))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8, top: 4, bottom: 4),
                    child: Text(
                      "${list![index]?.insurancePartner ?? ""}",
                      style: TextStyle(
                          fontSize: 15, color: PlunesColors.BLACKCOLOR),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        itemCount:
            (widget.func != null && list!.length > 10) ? 10 : list?.length ?? 0,
      ),
    );
  }

  List<InsuranceProvider>? _getListItems(List<InsuranceProvider> list) {
    return (_policySearchController!.text.trim().isNotEmpty &&
            (_searchedItemList == null || _searchedItemList!.isEmpty))
        ? list
        : (_searchedItemList != null && _searchedItemList!.isNotEmpty)
            ? _searchedItemList
            : _insuranceModel!.data;
  }
}
