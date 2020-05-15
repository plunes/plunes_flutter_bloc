import 'package:plunes/models/solution_models/solution_model.dart';

class PrevSearchedSolution {
  bool success;
  bool topSearches;
  List<CatalogueData> data;

  PrevSearchedSolution({this.success, this.data});

  PrevSearchedSolution.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    topSearches = json['topSearches'];
    if (json['data'] != null) {
      print(json['data'].toString());
      data = new List<CatalogueData>();
      json['data'].forEach((v) {
        data.add(CatalogueData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['topSearches'] = this.topSearches;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
