class ShareableReportModel {
  bool success;
  Link link;

  ShareableReportModel({this.success, this.link});

  ShareableReportModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    link = (json['data'] != null) ? new Link.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.link != null) {
      data['link'] = this.link.toJson();
    }
    return data;
  }
}

class Link {
  String sId;
  String reportName;
  String reportUrl;

  Link({this.sId, this.reportName, this.reportUrl});

  Link.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    reportName = json['reportName'];
    reportUrl = json['reportUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['reportName'] = this.reportName;
    data['reportUrl'] = this.reportUrl;
    return data;
  }
}
