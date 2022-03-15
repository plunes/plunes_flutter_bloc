import 'dart:io';

import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/repositories/new_solution_repo/submit_user_medical_detail_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class UserMedicalDetailBloc extends BlocBase {
  final _submitDetailStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get submitDetailStream =>
      _submitDetailStreamProvider.stream;
  final _uploadFileStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get uploadFileStream =>
      _uploadFileStreamProvider.stream;

  final _fetchDetailStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get fetchDetailStream =>
      _fetchDetailStreamProvider.stream;

  Future<RequestState> submitUserMedicalDetail(
      Map<String, dynamic> postData) async {
    addIntoSubmitMedicalDetailStream(RequestInProgress());
    var result = await SubmitMedicalDetailRepo().submitUserMedicalDetail(postData);
    addIntoSubmitMedicalDetailStream(result);
    return result;
  }

  @override
  void dispose() {
    _submitDetailStreamProvider?.close();
    _uploadFileStreamProvider?.close();
    _fetchDetailStreamProvider?.close();
    super.dispose();
  }

  void addIntoSubmitMedicalDetailStream(RequestState data) {
    super.addStateInGenericStream(_submitDetailStreamProvider, data);
  }

  Future<RequestState> uploadFile(File file,
      {String fileType,
      Map<String, dynamic> fileData,
      bool shouldShowUploadProgress = false}) async {
    addIntoSubmitFileStream(RequestInProgress());
    var result = await SubmitMedicalDetailRepo().uploadFile(file,
        fileType: fileType, fileUploadProgress: (num progress) {
      if (progress != null && shouldShowUploadProgress) {
        addIntoSubmitFileStream(RequestInProgress(data: progress));
      }
    });
    addIntoSubmitFileStream(result);
    return result;
  }

  void addIntoSubmitFileStream(RequestState data) {
    super.addStateInGenericStream(_uploadFileStreamProvider, data);
  }

  Future<RequestState> fetchUserMedicalDetail(CatalogueData catalogueData) async {
    addIntoFetchMedicalDetailStream(RequestInProgress());
    var result =
        await SubmitMedicalDetailRepo().fetchUserMedicalDetail(catalogueData);
    addIntoFetchMedicalDetailStream(result);
    return result;
  }

  void addIntoFetchMedicalDetailStream(RequestState data) {
    super.addStateInGenericStream(_fetchDetailStreamProvider, data);
  }
}
