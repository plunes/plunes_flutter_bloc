import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/doc_hos_repo/doc_hos_main_screen_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class DocHosMainInsightBloc extends BlocBase {
  final _realTimeProvider = PublishSubject<RequestState>();

  Observable<RequestState> get realTimeInsightStream =>
      _realTimeProvider.stream;

  final _realTimePriceUpdateProvider = PublishSubject<RequestState>();

  Observable<RequestState> get realTimePriceUpdateStream =>
      _realTimePriceUpdateProvider.stream;

  final _actionableProvider = PublishSubject<RequestState>();

  Observable<RequestState> get actionableStream => _actionableProvider.stream;

  // ignore: close_sinks
  final _actionablePriceUpdateProvider = PublishSubject<RequestState>();

  Observable<RequestState> get actionablePriceUpdateStream =>
      _actionablePriceUpdateProvider.stream;

  final _businessDataProvider = PublishSubject<RequestState>();

  Observable<RequestState> get businessDataStream =>
      _businessDataProvider.stream;

  addStateInRealTimeInsightStream(RequestState state) {
    super.addStateInGenericStream(_realTimeProvider, state);
  }

  addStateInActionableInsightStream(RequestState state) {
    super.addStateInGenericStream(_actionableProvider, state);
  }

  addStateInBusinessStream(RequestState state) {
    super.addStateInGenericStream(_businessDataProvider, state);
  }

  updateRealTimeInsightPriceStream(RequestState state) {
    super.addStateInGenericStream(_realTimePriceUpdateProvider, state);
  }

  addStateInActionableUpdatePriceStream(RequestState state) {
    super.addStateInGenericStream(_actionablePriceUpdateProvider, state);
  }

  @override
  void dispose() {
    _realTimeProvider?.close();
    _actionableProvider?.close();
    _realTimePriceUpdateProvider?.close();
    _businessDataProvider?.close();
    _actionablePriceUpdateProvider.close();
    super.dispose();
  }

  getRealTimeInsights() async {
    addStateInRealTimeInsightStream(
        await DocHosMainRepo().getRealTimeInsights());
  }

  getActionableInsights() async {
    addStateInActionableInsightStream(
        await DocHosMainRepo().getActionableInsights());
  }

  getTotalBusinessData(int days) async {
    addStateInBusinessStream(
        await DocHosMainRepo().getTotalBusinessEarnedAndLoss(days));
  }

  getUpdateRealTimeInsightPrice(num price, String solutionId,
      String serviceId) async {
    updateRealTimeInsightPriceStream(await DocHosMainRepo()
        .updateRealTimeIsightPrice(price, solutionId, serviceId));
  }

  getUpdateActionableInsightPrice(num price, String serviceId, String specialityId ) async {
    addStateInActionableUpdatePriceStream(
        await DocHosMainRepo().updateActionableInsightPrice(price, serviceId, specialityId));
  }
}
