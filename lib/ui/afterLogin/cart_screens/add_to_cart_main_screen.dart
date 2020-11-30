import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/blocs/cart_bloc/cart_main_bloc.dart';
import 'package:plunes/models/cart_models/cart_main_model.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:plunes/res/AssetsImagesFile.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/ui/afterLogin/cart_screens/patient_details_edit_popup_screen.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';

// ignore: must_be_immutable
class AddToCartMainScreen extends BaseActivity {
  @override
  _AddToCartMainScreenState createState() => _AddToCartMainScreenState();
}

class _AddToCartMainScreenState extends BaseState<AddToCartMainScreen> {
  CartOuterModel _cartOuterModel;
  CartMainBloc _cartMainBloc;
  String _failureCause;
  StreamController _timerStream;
  Timer _timer;

  @override
  void initState() {
    _timerStream = StreamController.broadcast();
    _cartMainBloc = CartMainBloc();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timer = timer;
      if (mounted) {
        _timerStream.add(null);
      }
    });
    _getCartItems();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerStream?.close();
    _cartMainBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: widget.getAppBar(context, PlunesStrings.myCart, true),
          body: StreamBuilder<RequestState>(
              stream: _cartMainBloc.cartMainStream,
              initialData: _cartOuterModel == null ? RequestInProgress() : null,
              builder: (context, snapshot) {
                if (snapshot.data != null &&
                    snapshot.data is RequestInProgress) {
                  return CustomWidgets().getProgressIndicator();
                }
                if (snapshot.data != null && snapshot.data is RequestSuccess) {
                  RequestSuccess requestSuccess = snapshot.data;
                  _cartOuterModel = requestSuccess.response;
                  _cartMainBloc.addStateInCartMainStream(null);
                }
                if (snapshot.data != null && snapshot.data is RequestFailed) {
                  RequestFailed requestFailed = snapshot.data;
                  _failureCause = requestFailed.failureCause;
                  _cartMainBloc.addStateInCartMainStream(null);
                }
                return (_failureCause != null)
                    ? CustomWidgets().errorWidget(
                        _failureCause ?? "Unable to get data",
                        onTap: () => _getCartItems())
                    : _showBody();
              }),
          key: scaffoldKey),
      top: false,
      bottom: false,
    );
  }

  Widget _showBody() {
    return Container(
      color: PlunesColors.WHITECOLOR,
      child: _getMainView(),
    );
  }

  Widget _getMainView() {
    return Column(children: <Widget>[
      Expanded(child: _getCartListView()),
      StreamBuilder<Object>(
          stream: _timerStream.stream,
          builder: (context, snapshot) {
            double price = 0;
            int itemCount = 0;
            if (_cartOuterModel.data.bookingIds != null &&
                _cartOuterModel.data.bookingIds.isNotEmpty) {
              _cartOuterModel.data.bookingIds.forEach((element) {
                bool _isSolutionExpired = _solutionExpired(element);
                if (!_isSolutionExpired) {
                  price = price + element?.service?.newPrice?.first ?? 0;
                  itemCount++;
                }
              });
            }
            return _getButtonView(price, itemCount);
          })
    ]);
  }

  Widget _getCartListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return StreamBuilder<Object>(
            stream: _timerStream.stream,
            builder: (context, snapshot) {
              return getCartCard(index, _cartOuterModel.data.bookingIds[index],
                  _cartOuterModel.data.bookingIds.length - 1);
            });
      },
      itemCount: _cartOuterModel?.data?.bookingIds?.length ?? 0,
    );
  }

  Widget _getButtonView(double price, int itemCount) {
    if (itemCount == 0) {
      return Container();
    }
    return Card(
      color: PlunesColors.WHITECOLOR,
      margin: EdgeInsets.all(0),
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: AppConfig.verticalBlockSize * 2.8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Subtotal ($itemCount ${itemCount == 1 ? "item" : "items"}): ",
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: PlunesColors.BLACKCOLOR,
                      fontSize: 15),
                ),
                Text("\u20B9 $price",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: PlunesColors.GREENCOLOR,
                        fontSize: 15))
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  top: AppConfig.verticalBlockSize * 2,
                  left: AppConfig.horizontalBlockSize * 32,
                  right: AppConfig.horizontalBlockSize * 32),
              child: InkWell(
                onTap: () {
                  _checkCreditAvailableAndPay();
                  return;
                },
                onDoubleTap: () {},
                child: CustomWidgets().getRoundedButton(
                    PlunesStrings.payNow,
                    AppConfig.horizontalBlockSize * 8,
                    PlunesColors.GREENCOLOR,
                    AppConfig.horizontalBlockSize * 3,
                    AppConfig.verticalBlockSize * 1,
                    PlunesColors.WHITECOLOR,
                    borderColor: PlunesColors.SPARKLINGGREEN,
                    hasBorder: true),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getCartCard(int index, final BookingIds bookingIds, int totalItems) {
    bool _isSolutionExpired = _solutionExpired(bookingIds);
    int time = DateTime.now().millisecondsSinceEpoch;
    if (!_isSolutionExpired) {
      time = bookingIds.service.expirationTimer;
    }
    return Card(
      color: Color(CommonMethods.getColorHexFromStr("#FBFBFB")),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 3.0,
      margin: EdgeInsets.only(
          bottom: (index == totalItems) ? AppConfig.verticalBlockSize * 1.8 : 0,
          left: AppConfig.horizontalBlockSize * 2.5,
          right: AppConfig.horizontalBlockSize * 2.5,
          top: AppConfig.verticalBlockSize * 1.8),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: AppConfig.horizontalBlockSize * 2.5,
                    vertical: AppConfig.verticalBlockSize * 1.6),
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            _viewProfile(bookingIds);
                            return;
                          },
                          onDoubleTap: () {},
                          child: Container(
                            height: AppConfig.verticalBlockSize * 10.5,
                            width: AppConfig.horizontalBlockSize * 16.5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: Colors.transparent),
                            child: (bookingIds.service != null &&
                                    bookingIds.service.imageUrl != null &&
                                    bookingIds.service.imageUrl.isNotEmpty &&
                                    bookingIds.service.imageUrl
                                        .contains("https"))
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: CustomWidgets().getImageFromUrl(
                                        bookingIds.service.imageUrl,
                                        boxFit: BoxFit.cover),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        gradient: new LinearGradient(
                                            colors: [
                                              Color(0xffababab),
                                              Color(0xff686868)
                                            ],
                                            begin: FractionalOffset.topCenter,
                                            end: FractionalOffset.bottomCenter,
                                            stops: [0.0, 1.0],
                                            tileMode: TileMode.clamp)),
                                    child: Text(
                                        ("name" != ''
                                                ? CommonMethods.getInitialName(
                                                    bookingIds.service?.name)
                                                : '')
                                            .toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                AppConfig.extraLargeFont - 4,
                                            fontWeight: FontWeight.bold)),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                                left: AppConfig.horizontalBlockSize * 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  bookingIds.service?.name ?? PlunesStrings.NA,
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: PlunesColors.BLACKCOLOR,
                                      fontSize: 16),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 1.1),
                                  child: Text(
                                    bookingIds.serviceName ?? PlunesStrings.NA,
                                    textAlign: TextAlign.left,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: PlunesColors.BLACKCOLOR,
                                        fontSize: 15),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 1.1),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                          height:
                                              AppConfig.verticalBlockSize * 3,
                                          width:
                                              AppConfig.horizontalBlockSize * 5,
                                          child: Image.asset(
                                              plunesImages.locationIcon)),
                                      Text(
                                        "${bookingIds.service?.distance?.toStringAsFixed(1) ?? 1} km",
                                        textAlign: TextAlign.left,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: PlunesColors.GREYCOLOR,
                                            fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          flex: 4,
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Icon(
                                      Icons.star,
                                      color: PlunesColors.GREENCOLOR,
                                    ),
                                    Text(
                                      "${bookingIds.service?.rating?.toStringAsFixed(1) ?? 4.0}" ??
                                          PlunesStrings.NA,
                                      style: TextStyle(
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: AppConfig.verticalBlockSize * 2),
                                  child: Text(
                                      "\u20B9 ${bookingIds.service?.newPrice?.first?.toStringAsFixed(2) ?? 0}",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: PlunesColors.BLACKCOLOR,
                                          fontSize: 17)),
                                )
                              ],
                            ))
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: AppConfig.verticalBlockSize * 2),
                      child: Row(
                        children: List.generate(
                            500 ~/ 4,
                            (index) => Expanded(
                                  child: Container(
                                    color: index % 2 == 0
                                        ? Colors.transparent
                                        : PlunesColors.LIGHTGREYCOLOR,
                                    height: 2,
                                  ),
                                )),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                CommonMethods.getStringInCamelCase(
                                    bookingIds.patientName),
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: PlunesColors.BLACKCOLOR,
                                    fontSize: 15),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: AppConfig.verticalBlockSize * 1.1),
                                child: Text(
                                  (bookingIds.service != null &&
                                          bookingIds.appointmentTime != null &&
                                          bookingIds.appointmentTime.isNotEmpty)
                                      ? "${DateUtil.getDateFormat(DateTime.fromMillisecondsSinceEpoch(int.tryParse(bookingIds.appointmentTime)))}, ${DateUtil.getTimeWithAmAndPmFormat(DateTime.fromMillisecondsSinceEpoch(int.tryParse(bookingIds.appointmentTime)))}"
                                      : PlunesStrings.NA,
                                  textAlign: TextAlign.left,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: PlunesColors.BLACKCOLOR,
                                      fontSize: 15),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topRight,
                            child: StreamBuilder<RequestState>(
                                stream: _cartMainBloc.deleteItemStream,
                                builder: (context, snapshot) {
                                  if (snapshot.data is RequestInProgress) {
                                    RequestInProgress _requestInProgress =
                                        snapshot.data;
                                    if (_requestInProgress.data != null &&
                                        _requestInProgress.data.toString() ==
                                            bookingIds.sId)
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          CustomWidgets()
                                              .getProgressIndicator(),
                                        ],
                                      );
                                  }
                                  if (snapshot.data != null &&
                                      snapshot.data is RequestSuccess) {
                                    RequestSuccess _requestSuccess =
                                        snapshot.data;
                                    if (_requestSuccess.response != null &&
                                        _requestSuccess.response.toString() ==
                                            bookingIds.sId) {
                                      Future.delayed(Duration(milliseconds: 10))
                                          .then((value) {
                                        _showMessages(_requestSuccess
                                                .additionalData ??
                                            PlunesStrings.deleteSuccessfully);
                                        _getCartItems();
                                      });
                                      _cartMainBloc
                                          .addStateInDeleteCartItemStream(null);
                                    }
                                  }
                                  if (snapshot.data != null &&
                                      snapshot.data is RequestFailed) {
                                    RequestFailed requestFailed = snapshot.data;
                                    if (requestFailed.response != null &&
                                        requestFailed.response.toString() ==
                                            bookingIds.sId) {
                                      Future.delayed(Duration(milliseconds: 10))
                                          .then((value) {
                                        _showMessages(
                                            requestFailed.failureCause ??
                                                "Unable to delete item");
                                      });
                                      _cartMainBloc
                                          .addStateInDeleteCartItemStream(null);
                                    }
                                  }
                                  return InkWell(
                                    onTap: () {
                                      _cartMainBloc
                                          .deleteCartItem(bookingIds.sId);
                                      return;
                                    },
                                    onDoubleTap: () {},
                                    child: Container(
                                      margin: EdgeInsets.all(2.5),
                                      height: AppConfig.verticalBlockSize * 4,
                                      width: AppConfig.horizontalBlockSize * 6,
                                      child: Image.asset(
                                        PlunesImages.binImage,
                                        color: PlunesColors.BLACKCOLOR,
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return EditPatientDetailScreen(
                                        bookingIds, _cartMainBloc);
                                  }).then((value) {
                                if (value != null && value) {
                                  _showMessages(
                                      "Details submitted successfully");
                                  _getCartItems();
                                }
                              });
                            },
                            onDoubleTap: () {},
                            child: Container(
                              margin: EdgeInsets.all(2.5),
                              height: AppConfig.verticalBlockSize * 4,
                              width: AppConfig.horizontalBlockSize * 6,
                              child: Image.asset(
                                  PlunesImages.availability_edit_image),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              _isSolutionExpired
                  ? Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: FractionalOffset.topCenter,
                                end: FractionalOffset.bottomCenter,
                                colors: [
                              Colors.white60,
                              Colors.white70
                              // I don't know what Color this will be, so I can't use this
                            ])),
                        width: double.infinity,
                      ),
                    )
                  : Container(),
            ],
          ),
          _isSolutionExpired
              ? Container(
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 1.8,
                      vertical: AppConfig.verticalBlockSize * 1.5),
                  decoration: BoxDecoration(
                      color: Color(CommonMethods.getColorHexFromStr("#EFEFEF")),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0))),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                          child: Container(
                              margin: EdgeInsets.only(right: 3),
                              child: Text(
                                  PlunesStrings.priceExpiredNegotiateAgain))),
                      _getNegotiateButton(bookingIds)
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                )
              : Container(
                  margin: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.horizontalBlockSize * 2.5,
                      vertical: AppConfig.verticalBlockSize * 1.5),
                  decoration: BoxDecoration(
                      color: Color(CommonMethods.getColorHexFromStr("#EFEFEF")),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0))),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        PlunesImages.validForOneHourOnlyWatch,
                        scale: 3,
                      ),
                      _getTimerForTop(time)
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                )
        ],
      ),
    );
  }

  Widget _getTimerForTop(int _expirationTimer) {
    return StreamBuilder<Object>(
        stream: _timerStream.stream,
        builder: (context, snapshot) {
          String value = "Valid for 1 hour only";
          bool shouldShowRichText = false;
          if (_expirationTimer != null) {
            var dateTimeNow = DateTime.now();
            if (dateTimeNow
                    .difference(
                        DateTime.fromMillisecondsSinceEpoch(_expirationTimer))
                    .inMinutes >=
                60) {
              value = "Prices Expired";
            } else if (dateTimeNow
                        .difference(DateTime.fromMillisecondsSinceEpoch(
                            _expirationTimer))
                        .inMinutes <
                    60 &&
                dateTimeNow
                        .difference(DateTime.fromMillisecondsSinceEpoch(
                            _expirationTimer))
                        .inMinutes >
                    0) {
              value =
                  "${60 - dateTimeNow.difference(DateTime.fromMillisecondsSinceEpoch(_expirationTimer)).inMinutes} min";
              shouldShowRichText = true;
            }
          }
          return shouldShowRichText
              ? Padding(
                  child: RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(
                              text: value ?? "",
                              style: TextStyle(
                                  color: PlunesColors.GREENCOLOR,
                                  fontSize: 16)),
                          TextSpan(
                              text: " only",
                              style: TextStyle(
                                  color: PlunesColors.GREYCOLOR, fontSize: 15)),
                        ],
                        text: PlunesStrings.validForOneHour,
                        style: TextStyle(
                            color: PlunesColors.GREYCOLOR, fontSize: 15)),
                  ),
                  padding: EdgeInsets.only(left: 4.0),
                )
              : Container(
                  margin:
                      EdgeInsets.only(left: AppConfig.horizontalBlockSize * 4),
                  child: Text(value,
                      style: TextStyle(
                          color: PlunesColors.GREYCOLOR, fontSize: 15)),
                );
        });
  }

  void _getCartItems() {
    _failureCause = null;
    _cartMainBloc.getCartItems();
  }

  void _showMessages(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets()
              .getInformativePopup(message: message, globalKey: scaffoldKey);
        });
  }

  bool _solutionExpired(BookingIds bookingIds) {
    bool _solutionExpired = false;
    if (bookingIds.service != null &&
        bookingIds.service.expirationTimer != null &&
        bookingIds.service.expirationTimer > 0) {
      var duration = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(
              bookingIds.service.expirationTimer));
      if (duration.inHours >= 1) {
        _solutionExpired = true;
      }
    }
    return _solutionExpired;
  }

  Widget _getNegotiateButton(BookingIds bookingIds) {
    return StreamBuilder<RequestState>(
        stream: _cartMainBloc.reGenerateCartItemStream,
        builder: (context, snapshot) {
          if (snapshot.data is RequestInProgress) {
            RequestInProgress _requestInProgress = snapshot.data;
            if (_requestInProgress.data != null &&
                _requestInProgress.data.toString() == bookingIds.sId)
              return CustomWidgets().getProgressIndicator();
          }
          if (snapshot.data != null && snapshot.data is RequestSuccess) {
            RequestSuccess _requestSuccess = snapshot.data;
            if (_requestSuccess.response != null &&
                _requestSuccess.response.toString() == bookingIds.sId) {
              Future.delayed(Duration(milliseconds: 10)).then((value) {
                _showMessages("Booking retained successfully!");
                _getCartItems();
              });
              _cartMainBloc.addStateInReGenerateCartItemStream(null);
            }
          }
          if (snapshot.data != null && snapshot.data is RequestFailed) {
            RequestFailed requestFailed = snapshot.data;
            if (requestFailed.response != null &&
                requestFailed.response.toString() == bookingIds.sId) {
              Future.delayed(Duration(milliseconds: 10)).then((value) {
                _showMessages(
                    requestFailed.failureCause ?? "Unable to negotiate");
              });
              _cartMainBloc.addStateInReGenerateCartItemStream(null);
            }
          }
          return InkWell(
            onTap: () {
              _cartMainBloc.reGenerateCartItem(bookingIds.sId);
            },
            onDoubleTap: () {},
            child: CustomWidgets().getRoundedButton(
                PlunesStrings.negotiate,
                AppConfig.horizontalBlockSize * 8,
                PlunesColors.GREENCOLOR,
                AppConfig.horizontalBlockSize * 3,
                AppConfig.verticalBlockSize * 1,
                PlunesColors.WHITECOLOR,
                borderColor: PlunesColors.SPARKLINGGREEN,
                hasBorder: true),
          );
        });
  }

  _viewProfile(final BookingIds booking) {
    if (booking.service != null &&
        booking.service.userType != null &&
        booking.professionalId != null) {
      Widget route;
      if (booking.service.userType.toLowerCase() ==
          Constants.doctor.toString().toLowerCase()) {
        route = DocProfile(userId: booking.professionalId);
      } else {
        route = HospitalProfile(userID: booking.professionalId);
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    }
  }

  void _checkCreditAvailableAndPay() {
//    showDialog(
//        context: context,
//        builder: (context) {
//          return CustomWidgets().openCartPaymentBillPopup();
//        });
  }
}
