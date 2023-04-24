import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/user_bloc.dart';
import 'package:plunes/models/Models.dart';
import 'package:plunes/models/cart_models/cart_main_model.dart';
import 'package:plunes/models/new_solution_model/bank_offer_model.dart';
import 'package:plunes/models/new_solution_model/premium_benefits_model.dart';
import 'package:plunes/repositories/user_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/new_common_widgets/common_widgets.dart';

// ignore: must_be_immutable
class CartProceedScreen extends BaseActivity {
  List<BookingIds> bookingIds;
  num? price, credits;
  CartOuterModel? cartOuterModel;

  CartProceedScreen(this.price, this.bookingIds,
      {this.credits, this.cartOuterModel});

  @override
  _CartProceedScreenState createState() => _CartProceedScreenState();
}

// class _CartProceedScreenState extends BaseState<CartProceedScreen> {
class _CartProceedScreenState extends State<CartProceedScreen> {
final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  User? _userData;
  PremiumBenefitsModel? _premiumBenefitsModel;
  late UserBloc _userBloc;
  BankOfferModel? _bankModel;
  bool _useCredits = false;

  @override
  void initState() {
    _userData = UserManager().getUserDetails();
    _userBloc = UserBloc();
    _getPremiumBenefitsForUsers();
    _getBankOffer();
    super.initState();
  }

  _getPremiumBenefitsForUsers() {
    _userBloc.getPremiumBenefitsForUsers().then((value) {
      if (value is RequestSuccess) {
        _premiumBenefitsModel = value.response;
      } else if (value is RequestFailed) {}
      _setState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: getAppBar(context, "Checkout", true) as PreferredSizeWidget?,
        body: _getBody(),
      ),
      top: false,
      bottom: false,
    );
  }

  Widget getAppBar(BuildContext context, String title, bool isIosBackButton,
      {Function? func}) {
    return AppBar(
        automaticallyImplyLeading: isIosBackButton,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        leading: isIosBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  if (func != null) {
                    func();
                  }
                  Navigator.pop(context);
                  return;
                },
              )
            : Container(),
        title: widget.createTextViews(
            title, 18, colorsFile.black, TextAlign.center, FontWeight.w500));
  }

  Widget _getBody() {
    return Container(
      color: Color(CommonMethods.getColorHexFromStr("#F9FAFB")),
      child: SingleChildScrollView(
          child: Column(
        children: [
          _getUserNameAndPriceView(),
          _getOtherWidgets(),
        ],
      )),
    );
  }

  Widget _getUserNameAndPriceView() {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(CommonMethods.getColorHexFromStr("#4FBF67")),
        Color(CommonMethods.getColorHexFromStr("#88E1A4"))
      ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
      padding: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 5,
          vertical: AppConfig.verticalBlockSize * 2.5),
      child: Row(
        children: [
          Flexible(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Container(
                      height: 55,
                      width: 55,
                      child: ClipOval(
                          child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle),
                        child: CustomWidgets().getImageFromUrl(
                            _userData?.imageUrl ?? "",
                            boxFit: BoxFit.fill),
                      )),
                    ),
                    radius: 27.5,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3),
                    child: Text(
                      "Hello, ${_getFirstName()}",
                      style: TextStyle(
                          fontSize: 23,
                          color: Color(
                              CommonMethods.getColorHexFromStr("#FFFFFF"))),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        "Your Total is",
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(
                                CommonMethods.getColorHexFromStr("#FFFFFF"))),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 3),
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "\u20B9 ${widget.price}",
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 38,
                              color: Color(
                                  CommonMethods.getColorHexFromStr("#FFFFFF"))),
                        ),
                      ),
                    ),
                  ]),
            ),
          )
        ],
      ),
    );
  }

  String _getFirstName() {
    String userName = "User";
    if (_userData!.name != null && _userData!.name!.trim().isNotEmpty) {
      if (_userData!.name!.split(" ") != null &&
          _userData!.name!.split(" ").isNotEmpty) {
        userName = _userData!.name!.split(" ").first;
      } else {
        userName = "";
      }
    }
    return userName;
  }

  Widget _offerWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              _bankModel!.confirmTitle ?? "Confirm Your booking & Pay Now",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          // Container(
          //   margin: EdgeInsets.only(top: 4),
          //   child: Text(
          //     _bankModel?.benefitDescription ??
          //         "Please make the payment after that you can enjoy the service and benefit of Plunes",
          //     style: TextStyle(
          //         fontSize: 14,
          //         color: Color(CommonMethods.getColorHexFromStr("#464646"))),
          //   ),
          // ),
          ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                height: 148,
                width: double.infinity,
                margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 1.5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  child: CustomWidgets().getImageFromUrl(
                      _bankModel?.data![index]?.titleImage ?? '',
                      boxFit: BoxFit.fill),
                ),
              );
            },
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _bankModel?.data?.length ?? 0,
          ),
        ],
      ),
    );
  }

  Widget _getOtherWidgets() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppConfig.horizontalBlockSize * 2.5,
          vertical: AppConfig.verticalBlockSize * 1.5),
      child: Column(
        children: [
          (_bankModel == null ||
                  _bankModel!.success == null ||
                  !_bankModel!.success! ||
                  _bankModel!.data == null ||
                  _bankModel!.data!.isEmpty)
              ? Container()
              : _offerWidget(),
          _getCartItemsWidget(),
          _getContinueButton(),
          _getBenefitsWidget()
        ],
      ),
    );
  }

  Widget _getCartItemsWidget() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 3),
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: AppConfig.verticalBlockSize * 2.5,
            horizontal: AppConfig.horizontalBlockSize * 4.5),
        child: Column(
          children: [
            (widget.cartOuterModel != null &&
                    widget.cartOuterModel!.data != null &&
                    widget.cartOuterModel!.data!.cartId != null &&
                    widget.cartOuterModel!.data!.cartId!.trim().isNotEmpty)
                ? Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order Id",
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#646464"))),
                          ),
                          Container(
                            child: Text(
                              widget.cartOuterModel!.data!.cartId ?? "",
                              style: TextStyle(
                                  fontSize: 18, color: PlunesColors.BLACKCOLOR),
                            ),
                          )
                        ],
                      ),
                      Expanded(child: Container()),
                      Container(
                        child: CustomWidgets().getRoundedButton(
                            "Unpaid",
                            AppConfig.horizontalBlockSize * 8,
                            Color(CommonMethods.getColorHexFromStr("#ECF4F7")),
                            AppConfig.horizontalBlockSize * 5,
                            AppConfig.verticalBlockSize * 1,
                            Color(CommonMethods.getColorHexFromStr("#646464")),
                            borderColor: PlunesColors.SPARKLINGGREEN,
                            hasBorder: false),
                      )
                    ],
                  )
                : Container(),
            Container(
              margin: EdgeInsets.symmetric(
                  vertical: AppConfig.verticalBlockSize * 2),
              child: DottedLine(
                dashColor: Color(CommonMethods.getColorHexFromStr("#7070706E")),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(bottom: 5),
              child: Text(
                "Services",
                style: TextStyle(
                    fontSize: 16,
                    color: Color(CommonMethods.getColorHexFromStr("#646464"))),
              ),
            ),
            _getCartItemList(),
            _getUseCreditsWidget(),
            _getOrderTotalView()
          ],
        ),
      ),
    );
  }

  Widget _getCartItemList() {
    List<CartItemMiniModel> _itemList = _getItemFilteredList();
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${_itemList[index]?.serviceName ?? PlunesStrings.NA}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: PlunesColors.BLACKCOLOR,
                          fontWeight: FontWeight.normal,
                          fontSize: 18),
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 3),
                      alignment: Alignment.centerRight,
                      child: RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                  text: "\u20B9 ${!_itemList[index].haveInsurance! ? '${_itemList[index]?.amount ?? 0}' : '0'}",

                                  // text: "as\u20B9${_itemList[index]?.amount ?? 0}",
                                  style: const TextStyle(
                                      color: PlunesColors.BLACKCOLOR,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18))
                            ],
                            text:
                                "${String.fromCharCode(0x00D7)} ${_itemList[index]?.count ?? 1} ",
                            style: TextStyle(
                                color: Color(CommonMethods.getColorHexFromStr(
                                    "#707070")),
                                fontWeight: FontWeight.w500,
                                fontSize: 18)),
                      ),
                    ))
              ],
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                  top: 5,
                  right: AppConfig.horizontalBlockSize * 14.0,
                  bottom: AppConfig.verticalBlockSize * 2),
              alignment: Alignment.centerLeft,
              child: Text(
                CommonMethods.getStringInCamelCase(
                    _itemList[index]?.serviceProviderName)!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 14),
              ),
            ),
            _itemList.length == index + 1
                ? Container(
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 2),
                    child: DottedLine(
                      dashColor:
                          Color(CommonMethods.getColorHexFromStr("#7070706E")),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(
                        bottom: AppConfig.verticalBlockSize * 2),
                    height: 0.5,
                    width: double.infinity,
                    color: PlunesColors.GREYCOLOR,
                  ),
          ],
        );
      },
      itemCount: _itemList?.length ?? 0,
    );
  }

  List<CartItemMiniModel> _getItemFilteredList() {
    List<CartItemMiniModel> _itemList = [];
    if (widget.bookingIds != null && widget.bookingIds.isNotEmpty) {
      widget.bookingIds.forEach((element) {
        CartItemMiniModel _model = CartItemMiniModel(
            amount: element.service?.newPrice?.first ?? 0,
            count: 1,
            serviceName: element.serviceName,
            serviceProviderId: element.professionalId,
            serviceProviderName: element.service?.name,
            haveInsurance: element.haveInsurance);

        // print(_model.toString());
        // if (_itemList.contains(_model)) {
        //   CartItemMiniModel alreadyFilledItem =
        //       _itemList[_itemList.indexOf(_model)];
        //   if (alreadyFilledItem != null &&
        //       alreadyFilledItem.serviceName == _model.serviceName &&
        //       alreadyFilledItem.serviceProviderName ==
        //           _model.serviceProviderName) {
        //     alreadyFilledItem.count!+1;
        //   } else {
        //     _itemList.add(_model);
        //   }
        // } else {
          _itemList.add(_model);
        // }
      });
    }
    return _itemList;
  }

  Widget _getOrderTotalView() {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Order total",
                style: TextStyle(fontSize: 18, color: PlunesColors.BLACKCOLOR),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                "\u20B9 ${widget.price ?? 0}",
                style: TextStyle(
                    fontSize: 18,
                    color: PlunesColors.BLACKCOLOR,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getContinueButton() {
    return Container(
      margin: EdgeInsets.only(
          top: AppConfig.verticalBlockSize * 1,
          bottom: AppConfig.verticalBlockSize * 3,
          right: AppConfig.horizontalBlockSize * 30,
          left: AppConfig.horizontalBlockSize * 30),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, _useCredits);
          return;
        },
        onDoubleTap: () {},
        child: CustomWidgets().getRoundedButton(
            PlunesStrings.continueText,
            AppConfig.horizontalBlockSize * 8,
            PlunesColors.GREENCOLOR,
            AppConfig.horizontalBlockSize * 3,
            AppConfig.verticalBlockSize * 1,
            PlunesColors.WHITECOLOR,
            borderColor: PlunesColors.SPARKLINGGREEN,
            hasBorder: true),
      ),
    );
  }

  void _setState() {
    if (mounted) setState(() {});
  }

  Widget _getBenefitsWidget() {
    if (_premiumBenefitsModel == null ||
        _premiumBenefitsModel!.data == null ||
        _premiumBenefitsModel!.data!.isEmpty) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.only(
          top: AppConfig.verticalBlockSize * 0.4,
          bottom: AppConfig.verticalBlockSize * 1.8,
          left: AppConfig.horizontalBlockSize * 1.2,
          right: AppConfig.horizontalBlockSize * 1.2),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Premium benefits for our users",
              style: TextStyle(color: PlunesColors.BLACKCOLOR, fontSize: 18),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: AppConfig.verticalBlockSize * 1.8,
            ),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => CommonWidgets()
                  .getPremiumBenefitsWidget(_premiumBenefitsModel!.data![index]),
              itemCount: _premiumBenefitsModel!.data!.length,
            ),
          )
        ],
      ),
    );
  }

  void _getBankOffer() {
    _userBloc.getBankOffers().then((value) {
      if (value is RequestSuccess) {
        _bankModel = value.response;
      } else if (value is RequestFailed) {}
      _setState();
    });
  }


  Widget _getUseCreditsWidget() {
    return (widget.credits != null && widget.credits! > 0)
        ? Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: StatefulBuilder(
                    builder: (context, newState) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          _useCredits = !_useCredits;
                          newState(() {});
                        },
                        onDoubleTap: () {},
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                PlunesStrings.useCredits,
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18),
                              ),
                            ),
                            Expanded(child: Container()),
                            Container(
                              child: Text(
                                "${widget.credits?.toStringAsFixed(1)}",
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 3),
                              child: IgnorePointer(
                                ignoring: true,
                                child: Checkbox(
                                  value: _useCredits,
                                  activeColor: PlunesColors.GREENCOLOR,
                                  checkColor: Colors.yellow,
                                  onChanged: (s) {},
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: AppConfig.verticalBlockSize * 2,
                      top: AppConfig.verticalBlockSize * 1.8),
                  child: DottedLine(
                    dashColor:
                        Color(CommonMethods.getColorHexFromStr("#7070706E")),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}

class CartItemMiniModel {
  String? serviceName, serviceProviderName, serviceProviderId;
  bool? haveInsurance;

  @override
  String toString() {
    return 'CartItemMiniModel{serviceName: $serviceName, serviceProviderName: $serviceProviderName, serviceProviderId: $serviceProviderId, count: $count, amount: $amount, haveInsurance: $haveInsurance}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemMiniModel &&
          runtimeType == other.runtimeType &&
          serviceProviderId == other.serviceProviderId;

  @override
  int get hashCode => serviceProviderId.hashCode;
  num? count, amount;

  CartItemMiniModel(
      {this.serviceName,
      this.amount,
      this.count,
      this.serviceProviderName,
      this.serviceProviderId,
      this.haveInsurance});
}
