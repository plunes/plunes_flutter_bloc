import 'package:flutter/foundation.dart';
import 'package:plunes/blocs/base_bloc.dart';
import 'package:plunes/repositories/solution_repo/searched_solution_repo.dart';

class SearchSolutionBloc extends BlocBase {
  static const int initialIndex = 0;

  Future getSearchedSolution({
    @required String searchedString,
    int index = initialIndex,
  }) async {
    super.addIntoStream(await SearchedSolutionRepo()
        .getSearchedSolution(searchedString, index));
  }
}
