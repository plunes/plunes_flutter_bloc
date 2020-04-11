import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/solution_repo/PrevMissSolution.dart';
import 'package:plunes/requester/request_states.dart';

class PrevMissSolutionBloc extends BlocBase {
  Future<RequestState> getPreviousSolutions() async {
    var result = await PrevMissSolutionRepo().getPrevSolutions();
    super.addIntoStream(result);
    return result;
  }
}
