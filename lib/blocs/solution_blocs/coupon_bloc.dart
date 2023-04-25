import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/solution_repo/coupon_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class CouponBloc extends BlocBase {
  final _couponTextStreamProvider = PublishSubject<RequestState?>();

  Stream<RequestState?> get couponTextStream =>
      _couponTextStreamProvider.stream;

  Future<RequestState> sendCouponDetails(String couponDetail) async {
    addIntoStream(RequestInProgress());
    var result = await CouponRepo().sendCouponDetails(couponDetail);
    addIntoStream(result);
    return result;
  }

  @override
  void dispose() {
    _couponTextStreamProvider?.close();
    super.dispose();
  }

  Future<RequestState> getCouponText() async {
    addIntoCouponTextProviderStream(RequestInProgress());
    var result = await CouponRepo().getCouponText();
    addIntoCouponTextProviderStream(result);
    return result;
  }

  void addIntoCouponTextProviderStream(RequestState? state) {
    addStateInGenericStream(_couponTextStreamProvider, state);
  }
}
