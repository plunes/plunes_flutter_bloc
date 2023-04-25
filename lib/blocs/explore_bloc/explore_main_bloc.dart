import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/explore_repo/explore_main_repo.dart';
import 'package:plunes/requester/request_states.dart';

class ExploreMainBloc extends BlocBase {
  static const int section1 = 0,
      section2 = 1,
      section3 = 2,
      section4 = 3,
      section5 = 4;

  Future<RequestState> getExploreData() async {
    addIntoStream(RequestInProgress());
    var result = await ExploreMainRepo().getExploreData();
    addIntoStream(result);
    return result;
  }

  @override
  void addIntoStream(RequestState? result) {
    super.addIntoStream(result);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
