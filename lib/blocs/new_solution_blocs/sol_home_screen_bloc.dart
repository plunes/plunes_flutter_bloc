import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/new_solution_repo/solution_home_page_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class HomeScreenMainBloc extends BlocBase {
  final _categoryStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getHomeScreenDetailStream =>
      _categoryStreamProvider.stream;
  final _whyUsStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getWhyUsStream => _whyUsStreamProvider.stream;

  final _whyUsCardByIdStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getWhyUsCardByIdStream =>
      _whyUsCardByIdStreamProvider.stream;

  @override
  void dispose() {
    _categoryStreamProvider?.close();
    _whyUsStreamProvider?.close();
    _whyUsCardByIdStreamProvider?.close();
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

  Future<RequestState> getWhyUsData() async {
    addIntoGetWhyUsDataStream(RequestInProgress());
    var result = await HomeScreenMainRepo().getWhyUsData();
    addIntoGetWhyUsDataStream(result);
    return result;
  }

  void addIntoGetWhyUsDataStream(RequestState state) {
    addStateInGenericStream(_whyUsStreamProvider, state);
  }

  Future<RequestState> getWhyUsDataById(String cardId) async {
    addIntoGetWhyUsDataByIdStream(RequestInProgress());
    var result = await HomeScreenMainRepo().getWhyUsDataById(cardId);
    addIntoGetWhyUsDataByIdStream(result);
    return result;
  }

  void addIntoGetWhyUsDataByIdStream(RequestState state) {
    addStateInGenericStream(_whyUsCardByIdStreamProvider, state);
  }
}
