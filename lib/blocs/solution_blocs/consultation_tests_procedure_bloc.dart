import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/solution_repo/consultataion_test_procedure_repo.dart';
import 'package:plunes/requester/request_states.dart';

class ConsultationTestProcedureBloc extends BlocBase {
  Future getConsultations() async {
    // super.addIntoStream(await ConsultationTestProcedureRepo().getConsultations());

    addIntoStream(RequestInProgress());
    var result = await ConsultationTestProcedureRepo().getConsultations();
    super.addIntoStream(result);
    return result;

  }

  void addState(RequestState requestState) {
    super.addIntoStream(requestState);
  }

  Future getDetails(bool isProcedure) async {
    // super.addIntoStream(await ConsultationTestProcedureRepo().getDetails(isProcedure));

    addIntoStream(RequestInProgress());
    var result = await ConsultationTestProcedureRepo().getDetails(isProcedure);
    super.addIntoStream(result);
    return result;
  }
}
