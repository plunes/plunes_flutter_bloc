import 'dart:io';

import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/plokr_repo/plokr_repo.dart';
import 'package:plunes/requester/request_states.dart';
import 'package:rxdart/rxdart.dart';

class PlockrBloc extends BlocBase {
  final _uploadStreamProvider = PublishSubject<RequestState>();

  Observable<RequestState> get uploadStream => _uploadStreamProvider.stream;
  
  
  @override
  void dispose() {
   _uploadStreamProvider.close();
    super.dispose();
  }

  uploadFilesAndData(Map<String, dynamic> postData,) async {
   // addStateInGenericStream(_uploadStreamProvider,RequestInProgress());
    var result =  await PlockrRepo().uploadPlockrData(postData);
  // addStateInGenericStream(_uploadStreamProvider, result);
     return result;
  }
  
} 