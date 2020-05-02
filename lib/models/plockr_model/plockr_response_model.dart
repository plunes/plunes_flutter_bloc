class PlockrResponseModel {
  bool success;
  List<UploadedReports> uploadedReports;
  List<UploadedReports> sharedReports;

  PlockrResponseModel({this.success, this.uploadedReports, this.sharedReports});

  PlockrResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['uploadedReports'] != null) {
      uploadedReports = new List<UploadedReports>();
      json['uploadedReports'].forEach((v) {
        uploadedReports.add(new UploadedReports.fromJson(v));
      });
    }
    if (json['sharedReports'] != null) {
      sharedReports = new List<Null>();
      json['sharedReports'].forEach((v) {
        sharedReports.add(new UploadedReports.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.uploadedReports != null) {
      data['uploadedReports'] =
          this.uploadedReports.map((v) => v.toJson()).toList();
    }
    if (this.sharedReports != null) {
      data['sharedReports'] =
          this.sharedReports.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UploadedReports {
  bool self;
  String sId;
  String userId;
  String uploader;
  String reportName;
  String reportDisplayName;
  String remarks;
 // List<UploadedReports> accessList;
  int createdTime;
  int iV;
  String userName;
  String userAddress;
  String reportUrl;
  String reportThumbnail;

  UploadedReports(
      {this.self,
        this.sId,
        this.userId,
        this.uploader,
        this.reportName,
        this.reportDisplayName,
        this.remarks,
      //  this.accessList,
        this.createdTime,
        this.iV,
        this.userName,
        this.userAddress,
        this.reportUrl,
        this.reportThumbnail});

  UploadedReports.fromJson(Map<String, dynamic> json) {
    self = json['self'];
    sId = json['_id'];
    userId = json['userId'];
    uploader = json['uploader'];
    reportName = json['reportName'];
    reportDisplayName = json['reportDisplayName'];
    remarks = json['remarks'];
//    if (json['accessList'] != null) {
//      accessList = new List<UploadedReports>();
//      json['accessList'].forEach((v) {
//        accessList.add(new UploadedReports.fromJson(v));
//      });
  //}
    createdTime = json['createdTime'];
    iV = json['__v'];
    userName = json['userName'];
    userAddress = json['userAddress'];
    reportUrl = json['reportUrl'];
    reportThumbnail = json['reportThumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['self'] = this.self;
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['uploader'] = this.uploader;
    data['reportName'] = this.reportName;
    data['reportDisplayName'] = this.reportDisplayName;
    data['remarks'] = this.remarks;
//    if (this.accessList != null) {
//      data['accessList'] = this.accessList.map((v) => v.toJson()).toList();
//    }
    data['createdTime'] = this.createdTime;
    data['__v'] = this.iV;
    data['userName'] = this.userName;
    data['userAddress'] = this.userAddress;
    data['reportUrl'] = this.reportUrl;
    data['reportThumbnail'] = this.reportThumbnail;
    return data;
  }
}