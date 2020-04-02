import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/solution_repo/consultataion_test_procedure_repo.dart';
import 'package:plunes/requester/request_states.dart';

class ConsultationTestProcedureBloc extends BlocBase {
  Future getConsultations() async {
    super.addIntoStream(
        await ConsultationTestProcedureRepo().getConsultations());
  }

  void addState(RequestState requestState) {
    super.addIntoStream(requestState);
  }

  void getDetails(bool isProcedure) async {
    super.addIntoStream(
        await ConsultationTestProcedureRepo().getDetails(isProcedure));
  }
}
