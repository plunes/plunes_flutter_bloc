import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/cart_main_repo/cart_main_repo.dart';
import 'package:plunes/requester/request_states.dart';

class CartMainBloc extends BlocBase {
  Future<RequestState> addItemToCart(Map<String, dynamic> postData) async {
    addIntoStream(RequestInProgress());
    var result = await CartMainRepo().addItemToCart(postData);
    addIntoStream(result);
    return result;
  }

  @override
  void addIntoStream(RequestState result) {
    super.addIntoStream(result);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
