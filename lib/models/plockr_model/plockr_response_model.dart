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
      sharedReports = new List<UploadedReports>();
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadedReports &&
          runtimeType == other.runtimeType &&
          sId == other.sId;

  @override
  int get hashCode => sId.hashCode;
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
  String fileType;
  String reasonDiagnosis;
  String medicines;
  String test;
  String consumptionDiet;
  String avoidDiet;
  String precautions;
  static const String dicomFile = ".dcm";
  static const String jpgFile = '.jpg';
  static const String pdfFile = '.pdf';

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
      this.reportThumbnail,
        this.fileType,
      this.reasonDiagnosis,
      this.medicines,
      this.test,
      this.consumptionDiet,
      this.avoidDiet,
      this.precautions});

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
    fileType = json['fileType'];
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
    data['fileType'] = this.fileType;
    return data;
  }
}
