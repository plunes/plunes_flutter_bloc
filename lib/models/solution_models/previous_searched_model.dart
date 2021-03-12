import 'package:plunes/models/solution_models/solution_model.dart';

class PrevSearchedSolution {
  bool success;
  bool topSearches;
  List<CatalogueData> data;
  String subTitle;

  PrevSearchedSolution(
      {this.success, this.data, this.subTitle, this.topSearches});

  PrevSearchedSolution.fromJson(Map<String, dynamic> json) {
//    print(" ${json['topSearches']} json $json");
    success = json['success'];
    subTitle = json['subTitle'];
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
