import 'dart:io';

import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/new_solution_repo/submit_user_medical_detail_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class SubmitUserMedicalDetailBloc extends BlocBase {
  final _submitDetailStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get submitDetailStream =>
      _submitDetailStreamProvider.stream;
  final _uploadFileStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get uploadFileStream =>
      _uploadFileStreamProvider.stream;

  Future<RequestState> submitUserMedicalDetail(
      Map<String, dynamic> postData) async {
    addIntoSubmitMedicalDetailStream(RequestInProgress());
    var result =
        await SubmitMedicalDetailRepo().submitUserMedicalDetail(postData);
    addIntoSubmitMedicalDetailStream(result);
    return result;
  }

  @override
  void dispose() {
    _submitDetailStreamProvider?.close();
    _uploadFileStreamProvider?.close();
    super.dispose();
  }

  void addIntoSubmitMedicalDetailStream(RequestInProgress data) {
    super.addStateInGenericStream(_submitDetailStreamProvider, data);
  }

  Future<RequestState> uploadFile(File file,
      {String fileType, Map<String, dynamic> fileData}) async {
    addIntoSubmitFileStream(RequestInProgress());
    var result =
        await SubmitMedicalDetailRepo().uploadFile(file, fileType: fileType);
    addIntoSubmitFileStream(result);
    return result;
  }

  void addIntoSubmitFileStream(RequestState data) {
    super.addStateInGenericStream(_uploadFileStreamProvider, data);
  }
}
