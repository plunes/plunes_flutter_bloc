class InsuranceImageRespnse {
  Data? data;

  InsuranceImageRespnse(this.data);

  InsuranceImageRespnse.fromJson(Map<String, dynamic> json) {
    // data = json['data'];
    data = json['data'] != null
        ? new Data.fromJson(json['data'])
        : null;
  }

}

class Data {
  String? reportType;
  List<Reports>? reports;

  Data(this.reportType, this.reports);

  Data.fromJson(Map<String, dynamic> json) {
    reportType = json['reportType'];
    if (json['reports'] != null) {
      reports = [];
      json['reports'].forEach((v) {
        reports!.add(new Reports.fromJson(v));
      });
    }
  }
}

class Reports {
  String? key;
  String? url;

  Reports(this.key, this.url);

  Reports.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    url = json['url'];
  }

}