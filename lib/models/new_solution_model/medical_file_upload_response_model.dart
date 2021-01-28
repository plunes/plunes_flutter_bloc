class MedicalFileResponseModel {
  FileResponseData data;

  MedicalFileResponseModel({this.data});

  MedicalFileResponseModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? new FileResponseData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class FileResponseData {
  String reportType;
  List<UploadedReportUrl> reports;

  FileResponseData({this.reportType, this.reports});

  FileResponseData.fromJson(Map<String, dynamic> json) {
    reportType = json['reportType'];
    if (json['reports'] != null) {
      reports = new List<UploadedReportUrl>();
      json['reports'].forEach((v) {
        reports.add(new UploadedReportUrl.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['reportType'] = this.reportType;
    if (this.reports != null) {
      data['reports'] = this.reports.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UploadedReportUrl {
  String key;
  String url;

  UploadedReportUrl({this.key, this.url});

  UploadedReportUrl.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['url'] = this.url;
    return data;
  }
}
