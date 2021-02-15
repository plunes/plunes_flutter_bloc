import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/models/doc_hos_models/common_models/realtime_insights_response_model.dart';
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

  // ignore: close_sinks
  final _helpQueryDocHosProvider = PublishSubject<RequestState>();

  Observable<RequestState> get helpQueryDocHosStream =>
      _helpQueryDocHosProvider.stream;

  final _stopNotificationForSuggestedInsightProvider =
      PublishSubject<RequestState>();

  Observable<RequestState> get realTimeInsightStopNotificationStream =>
      _stopNotificationForSuggestedInsightProvider.stream;

  final _updatePriceInCatalogueFromRealInsightProvider =
      PublishSubject<RequestState>();

  Observable<RequestState> get updatePriceInCatalogueFromRealInsightStream =>
      _updatePriceInCatalogueFromRealInsightProvider.stream;

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

  addStateInHelpQueryStream(RequestState state) {
    super.addStateInGenericStream(_helpQueryDocHosProvider, state);
  }

  addStateInDoNotDisturbStream(RequestState state) {
    super.addStateInGenericStream(
        _stopNotificationForSuggestedInsightProvider, state);
  }

  addStatePriceUpdationInCatalogueStream(RequestState state) {
    super.addStateInGenericStream(
        _updatePriceInCatalogueFromRealInsightProvider, state);
  }

  @override
  void dispose() {
    _realTimeProvider?.close();
    _actionableProvider?.close();
    _realTimePriceUpdateProvider?.close();
    _businessDataProvider?.close();
    _actionablePriceUpdateProvider.close();
    _helpQueryDocHosProvider.close();
    _stopNotificationForSuggestedInsightProvider?.close();
    _updatePriceInCatalogueFromRealInsightProvider?.close();
    super.dispose();
  }

  getRealTimeInsights() async {
    addStateInRealTimeInsightStream(RequestInProgress());
    addStateInRealTimeInsightStream(
        await DocHosMainRepo().getRealTimeInsights());
  }

  getActionableInsights({String userId}) async {
    addStateInActionableInsightStream(RequestInProgress());
    addStateInActionableInsightStream(
        await DocHosMainRepo().getActionableInsights(userId: userId));
  }

  getTotalBusinessData(int days, {String userId}) async {
    addStateInBusinessStream(RequestInProgress());
    addStateInBusinessStream(await DocHosMainRepo()
        .getTotalBusinessEarnedAndLoss(days, userId: userId));
  }

  getUpdateRealTimeInsightPrice(num price, String solutionId, String serviceId,
      {bool isSuggestive = false,
      num suggestedPrice,
      RealInsight realInsight,
      String addOnText,
      String specialOfferText,
      String techniqueText}) async {
    updateRealTimeInsightPriceStream(RequestInProgress());
    updateRealTimeInsightPriceStream(await DocHosMainRepo()
        .updateRealTimeInsightPrice(price, solutionId, serviceId,
            isSuggestive: isSuggestive,
            suggestedPrice: suggestedPrice,
            realInsight: realInsight,
            techniqueText: techniqueText,
            specialOfferText: specialOfferText,
            addOnText: addOnText));
  }

  getUpdateActionableInsightPrice(
      num price, String serviceId, String specialityId,
      {String centreId}) async {
    addStateInActionableUpdatePriceStream(RequestInProgress());
    addStateInActionableUpdatePriceStream(await DocHosMainRepo()
        .updateActionableInsightPrice(price, serviceId, specialityId,
            centreId: centreId));
  }

  Future helpDocHosQuery(String query) async {
    addStateInHelpQueryStream(RequestInProgress());
    var result = await DocHosMainRepo().helpQuery(query);
    addStateInHelpQueryStream(result);
    return result;
  }

  Future stopNotificationsForSuggestedInsight(String serviceId) async {
    addStateInDoNotDisturbStream(RequestInProgress());
    var result =
        await DocHosMainRepo().stopNotificationsForSuggestedInsight(serviceId);
    addStateInDoNotDisturbStream(result);
    return result;
  }

  Future updatePriceInCatalogueFromRealInsight(
      String serviceId, num price, String profId) async {
    addStatePriceUpdationInCatalogueStream(RequestInProgress());
    var result = await DocHosMainRepo()
        .updatePriceInCatalogueFromRealInsight(serviceId, price, profId);
    addStatePriceUpdationInCatalogueStream(result);
    return result;
  }
}
