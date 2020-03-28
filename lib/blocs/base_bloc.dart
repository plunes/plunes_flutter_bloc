import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

abstract class BlocBase {
  final _baseStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get _baseStream => _baseStreamProvider.stream;

  get baseStreamProvider => _baseStreamProvider;

  get baseStream => _baseStream;

  void dispose() {
    _baseStreamProvider?.close();
  }
}
