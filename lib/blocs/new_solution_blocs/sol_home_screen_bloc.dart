import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/new_solution_repo/solution_home_page_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreenMainBloc extends BlocBase {
  final _categoryStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getHomeScreenDetailStream =>
      _categoryStreamProvider.stream;

  @override
  void dispose() {
    _categoryStreamProvider?.close();
    super.dispose();
  }

  Future<RequestState> getSolutionHomePageCategoryData() async {
    addIntoSolutionHomePageCategoryData(RequestInProgress());
    var result = await HomeScreenMainRepo().getSolutionHomePageCategoryData();
    addIntoSolutionHomePageCategoryData(result);
    return result;
  }

  void addIntoSolutionHomePageCategoryData(RequestState state) {
    addStateInGenericStream(_categoryStreamProvider, state);
  }
}
