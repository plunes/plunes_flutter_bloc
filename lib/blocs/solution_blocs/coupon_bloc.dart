import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/solution_repo/coupon_repo.dart';
import 'package:plunes/requester/request_states.dart';

class CouponBloc extends BlocBase {
  Future<RequestState> sendCouponDetails(String couponDetail) async {
    addIntoStream(RequestInProgress());
    var result = await CouponRepo().sendCouponDetails(couponDetail);
    addIntoStream(result);
    return result;
  }
}
