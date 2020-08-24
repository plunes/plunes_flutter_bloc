abstract class RequestState {}

class RequestFailed implements RequestState {
  final String failureCause;
  final int requestCode;
  final dynamic response;

  const RequestFailed({this.failureCause, this.requestCode, this.response});
}

class RequestSuccess implements RequestState {
  final dynamic response, additionalData;
  final int requestCode;

  const RequestSuccess({this.response, this.requestCode, this.additionalData});
}

class InitialState implements RequestState {
  final dynamic data;

  const InitialState({this.data});
}

class RequestInProgress implements RequestState {
  final dynamic data;
  final int requestCode;

  const RequestInProgress({this.data, this.requestCode});
}

class RequestInitialState implements RequestState {
  const RequestInitialState();
}

class ValidationSuccess implements RequestState {
  final int pageNo;
  final int validationType;

  ValidationSuccess({this.pageNo, this.validationType});
}

class ValidationFailed implements RequestState {
  final String failedReason;

  ValidationFailed({this.failedReason});
}
