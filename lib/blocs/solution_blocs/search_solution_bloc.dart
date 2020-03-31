import 'package:flutter/foundation.dart';
import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/solution_repo/searched_solution_repo.dart';

class SearchSolutionBloc extends BlocBase {
  Future getSearchedSolution({
    @required String searchedString,
    int index = 0,
  }) async {
    await SearchedSolutionRepo().getSearchedSolution(searchedString, index);
  }
}
