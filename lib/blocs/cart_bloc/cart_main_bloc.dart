import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/cart_main_repo/cart_main_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class CartMainBloc extends BlocBase {
  final _cartItemProvider = PublishSubject<RequestState>();

  Observable<RequestState> get cartMainStream => _cartItemProvider.stream;
  final _deleteCartItemProvider = PublishSubject<RequestState>();

  Observable<RequestState> get deleteItemStream =>
      _deleteCartItemProvider.stream;

  final _reGenerateCartItemProvider = PublishSubject<RequestState>();

  Observable<RequestState> get reGenerateCartItemStream =>
      _reGenerateCartItemProvider.stream;

  final _editInfoStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get editInfoStream => _editInfoStreamProvider.stream;

  final _payCartBillStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get payCartBillStream =>
      _payCartBillStreamProvider.stream;

  Future<RequestState> addItemToCart(Map<String, dynamic> postData) async {
    addIntoStream(RequestInProgress());
    var result = await CartMainRepo().addItemToCart(postData);
    addIntoStream(result);
    return result;
  }

  Future<RequestState> getCartItems() async {
    addStateInCartMainStream(RequestInProgress());
    var result = await CartMainRepo().getCartItems();
    addStateInCartMainStream(result);
    return result;
  }

  Future<RequestState> deleteCartItem(String itemId) async {
    addStateInDeleteCartItemStream(RequestInProgress(data: itemId));
    var result = await CartMainRepo().deleteCartItem(itemId);
    addStateInDeleteCartItemStream(result);
    return result;
  }

  Future<RequestState> reGenerateCartItem(String itemId) async {
    addStateInReGenerateCartItemStream(RequestInProgress(data: itemId));
    var result = await CartMainRepo().reGenerateCartItem(itemId);
    addStateInReGenerateCartItemStream(result);
    return result;
  }

  @override
  void addStateInGenericStream(
      PublishSubject publishSubject, RequestState data) {
    super.addStateInGenericStream(publishSubject, data);
  }

  @override
  void addIntoStream(RequestState result) {
    super.addIntoStream(result);
  }

  @override
  void dispose() {
    _cartItemProvider?.close();
    _deleteCartItemProvider?.close();
    _reGenerateCartItemProvider?.close();
    _editInfoStreamProvider?.close();
    _payCartBillStreamProvider?.close();
    super.dispose();
  }

  void addStateInCartMainStream(RequestState result) {
    addStateInGenericStream(_cartItemProvider, result);
  }

  void addStateInDeleteCartItemStream(RequestState result) {
    addStateInGenericStream(_deleteCartItemProvider, result);
  }

  void addStateInReGenerateCartItemStream(RequestState result) {
    addStateInGenericStream(_reGenerateCartItemProvider, result);
  }

  Future<RequestState> saveEditedPatientDetails(
      Map<String, dynamic> json) async {
    addStateInEditDetailsStream(RequestInProgress());
    var result = await CartMainRepo().saveEditedPatientDetails(json);
    addStateInEditDetailsStream(result);
    return result;
  }

  void addStateInEditDetailsStream(RequestState data) {
    addStateInGenericStream(_editInfoStreamProvider, data);
  }

  Future<RequestState> payCartItemBill(bool creditsUsed, String cartId,
      String paymentPercent, bool zestMoney) async {
    addStatePaymentStream(RequestInProgress());
    var result = await CartMainRepo()
        .payCartItemBill(creditsUsed, cartId, paymentPercent, zestMoney);
    addStatePaymentStream(result);
    return result;
  }

  void addStatePaymentStream(RequestState data) {
    addStateInGenericStream(_payCartBillStreamProvider, data);
  }
}
