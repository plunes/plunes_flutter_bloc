import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/doc_hos_repo/catalogue_service_repo.dart';

class CatalogueServiceBloc extends BlocBase {
  getServiceCatalogues() async {
    super.addIntoStream(await CatalogueServiceRepo().getServiceCatalogues());
  }
}
