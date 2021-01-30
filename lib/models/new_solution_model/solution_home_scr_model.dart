class SolutionHomeScreenModel {
  bool success;
  String backgroundImage;
  int count;
  String knowYourProcedure,
      whyUs,
      topFacilities,
      topSearch,
      speciality,
      videos,
      heading,
      searchBarText;
  List<HomeScreenButtonInfo> data;

  SolutionHomeScreenModel(
      {this.success,
      this.backgroundImage,
      this.count,
      this.data,
      this.speciality,
      this.videos,
      this.knowYourProcedure,
      this.topFacilities,
      this.topSearch,
      this.whyUs,
      this.heading,
      this.searchBarText});

  SolutionHomeScreenModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    backgroundImage = json['backgroundImage'];
    count = json['count'];
    knowYourProcedure = json['knowYourProcedure'];
    whyUs = json['whyUs'];
    topFacilities = json['topFacilities'];
    topSearch = json['topSearch'];
    speciality = json['speciality'];
    videos = json['videos'];
    heading = json['homeTitle'];
    searchBarText = json['searchText'];
    if (json['data'] != null) {
      data = new List<HomeScreenButtonInfo>();
      json['data'].forEach((v) {
        data.add(new HomeScreenButtonInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['backgroundImage'] = this.backgroundImage;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HomeScreenButtonInfo {
  int index;
  String category;
  String categoryName;
  String categoryImage;

  HomeScreenButtonInfo(
      {this.index, this.category, this.categoryName, this.categoryImage});

  HomeScreenButtonInfo.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    category = json['category'];
    categoryName = json['categoryName'];
    categoryImage = json['categoryImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['index'] = this.index;
    data['category'] = this.category;
    data['categoryName'] = this.categoryName;
    data['categoryImage'] = this.categoryImage;
    return data;
  }
}
