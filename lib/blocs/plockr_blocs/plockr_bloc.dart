import 'dart:io';

import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/plokr_repo/plokr_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class PlockrBloc extends BlocBase {
  final _uploadStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get uploadStream => _uploadStreamProvider.stream;

  final _getPlockrFileStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getPlockrFileStream =>
      _getPlockrFileStreamProvider.stream;

  final _getSharebleFileLinkStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get getPlockrFileLinkStream =>
      _getSharebleFileLinkStreamProvider.stream;

  final _deletePlockrFileStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get deletePlockrFileStream =>
      _deletePlockrFileStreamProvider.stream;

  @override
  void dispose() {
    _uploadStreamProvider.close();
    _getPlockrFileStreamProvider.close();
    _getSharebleFileLinkStreamProvider.close();
    _deletePlockrFileStreamProvider.close();
    super.dispose();
  }

  Future<RequestState> uploadFilesAndData(
    Map<String, dynamic> postData,
  ) async {
    // addStateInGenericStream(_uploadStreamProvider,RequestInProgress());
    var result = await PlockrRepo().uploadPlockrData(postData);
    // addStateInGenericStream(_uploadStreamProvider, result);
    return result;
  }

  getFilesAndData() async {
    addStateInGenericStream(_getPlockrFileStreamProvider, RequestInProgress());
    var result = await PlockrRepo().getPlockrData();
    addStateInGenericStream(_getPlockrFileStreamProvider, result);
    return result;
  }

  getSharebleLink(String id) async {
    addStateInGenericStream(
        _getSharebleFileLinkStreamProvider, RequestInProgress());
    var result = await PlockrRepo().getSharableLink(id);
    addStateInGenericStream(_getSharebleFileLinkStreamProvider, result);
    return result;
  }

  deleteFileAndData(String id) async {
    addStateInGenericStream(
        _deletePlockrFileStreamProvider, RequestInProgress());
    var result = await PlockrRepo().deletePlockrFile(id);
    addStateInGenericStream(_deletePlockrFileStreamProvider, result);
    return result;
  }

  void addStateInPlockerReportStream(RequestState requestState) {
    addStateInGenericStream(_getPlockrFileStreamProvider, requestState);
  }
}
