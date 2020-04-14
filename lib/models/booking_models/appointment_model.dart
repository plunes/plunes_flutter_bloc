class Appointment {
  String professionalId;
  String solutionServiceId;
  String professionalName;
  String professionalAddress;
  String professionalMobileNumber;
  double lattitude;
  double logitude;
  double distance;
  String serviceId;
  String bookingStatus;
  String time_slot;
  String appointmentTime;
  String serviceName;
  bool rescheduled;
  String percentage;


  Appointment({
    this.professionalId,
    this.solutionServiceId,
    this.professionalName,
    this.professionalAddress,
    this.professionalMobileNumber,
    this.lattitude,
    this.logitude,
    this.distance,
    this.serviceId,
    this.bookingStatus,
    this.appointmentTime,
    this.serviceName,
    this.rescheduled,
    this.percentage,

});


  Appointment.fromJson(Map<String, dynamic> json) {
    professionalId = json['professionalId'];
    solutionServiceId = json['solutionServiceId'];
    serviceId = json['serviceId'];
    professionalName = json['professionalName'];
    professionalAddress = json['professionalAddress'];
    professionalMobileNumber = json['professionalMobileNumber'];
    lattitude = json['lattitude'];
    logitude = json['longitude'];
    bookingStatus =json['bookingStatus'];
    appointmentTime = json['appointmentTime'];
    serviceName = json['serviceName'];
    rescheduled = json['rescheduled'];
    percentage = json['percentage'];
  }

}
