import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/doc_hos_repo/doc_hos_main_screen_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class DocHosMainInsightBloc extends BlocBase {
  final _realTimeProvider = PublishSubject<RequestState>();

  Observable<RequestState> get realTimeInsightStream =>
      _realTimeProvider.stream;

  final _actionableProvider = PublishSubject<RequestState>();

  Observable<RequestState> get actionableStream => _actionableProvider.stream;
  final _realTimePriceUpdateProvider = PublishSubject<RequestState>();

  Observable<RequestState> get realTimePriceUpdateStream =>
      _realTimePriceUpdateProvider.stream;

  final _businessDataProvider = PublishSubject<RequestState>();

  Observable<RequestState> get businessDataStream =>
      _businessDataProvider.stream;

  getRealTimeInsights() async {
    addStateInRealTimeInsightStream(
        await DocHosMainRepo().getRealTimeInsights());
  }

  addStateInRealTimeInsightStream(RequestState state) {
    super.addStateInGenericStream(_realTimeProvider, state);
  }

  addStateInActionableInsightStream(RequestState state) {
    super.addStateInGenericStream(_actionableProvider, state);
  }
  addStateInBusinessStream(RequestState state){
    super.addStateInGenericStream(_businessDataProvider, state);
  }

  updateRealTimeInsightPrice() {
    ///start from here
  }

  @override
  void dispose() {
    _realTimeProvider?.close();
    _actionableProvider?.close();
    _realTimePriceUpdateProvider?.close();
    _businessDataProvider?.close();
    super.dispose();
  }

  getActionableInsights() async {
    addStateInActionableInsightStream(
        await DocHosMainRepo().getActionableInsights());
  }

  getTotalBusinessData(int days) async {
    addStateInBusinessStream(
      await DocHosMainRepo().getTotalBusinessEarnedAndLoss(days));
  }
}
