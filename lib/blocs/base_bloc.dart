import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

abstract class BlocBase {
  final _baseStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get _baseStream => _baseStreamProvider.stream;

  get baseStreamProvider => _baseStreamProvider;

  get baseStream => _baseStream;

  void addIntoStream(RequestState result) {
    if (_baseStreamProvider != null && !_baseStreamProvider.isClosed) {
      _baseStreamProvider.add(result);
    }
  }

  void addStateInGenericStream(
      PublishSubject publishSubject, RequestState data) {
    if (publishSubject != null && !publishSubject.isClosed) {
      publishSubject.add(data);
    }
  }

  void dispose() {
    _baseStreamProvider?.close();
  }
}
