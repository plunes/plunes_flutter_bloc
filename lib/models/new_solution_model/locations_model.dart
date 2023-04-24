import 'package:plunes/models/Models.dart';
import 'package:plunes/models/doc_hos_models/common_models/facility_collection_model.dart';
import 'package:plunes/models/solution_models/solution_model.dart';

class LocationAndServiceModel {
  bool? success;
  List<PopularCities>? popularCities, otherLocations;
  List<CatalogueData>? popularServices, otherServices;
  String? message;
  List<Facility>? facilities;

  LocationAndServiceModel(
      {this.success, this.popularCities, this.popularServices, this.message});

  LocationAndServiceModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['popularCities'] != null) {
      popularCities = [];
      json['popularCities'].forEach((v) {
        popularCities!.add(new PopularCities.fromJson(v));
      });
    }
    if (json['otherLocations'] != null) {
      otherLocations = [];
      json['otherLocations'].forEach((v) {
        otherLocations!.add(new PopularCities.fromJson(v));
      });
    }
    if (json['popularServices'] != null) {
      popularServices = [];
      json['popularServices'].forEach((v) {
        popularServices!.add(new CatalogueData.fromJson(v));
      });
    }
    if (json['otherServices'] != null) {
      otherServices = [];
      json['otherServices'].forEach((v) {
        otherServices!.add(new CatalogueData.fromJson(v));
      });
    }
    if (json['topFacilities'] != null) {
      facilities = [];
      json['topFacilities'].forEach((v) {
        facilities!.add(new Facility.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.popularCities != null) {
      data['popularCities'] =
          this.popularCities!.map((v) => v.toJson()).toList();
    }
    if (this.popularServices != null) {
      data['popularServices'] =
          this.popularServices!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class PopularCities {
  Location? location;
  String? sId;
  String? locality;
  int? iV;
  String? imageUrl;

  PopularCities(
      {this.location, this.sId, this.locality, this.iV, this.imageUrl});

  PopularCities.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    locality = json['locality'];
    iV = json['__v'];
    imageUrl = json['locationImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    data['locality'] = this.locality;
    data['__v'] = this.iV;
    return data;
  }
}

// class Location {
//   String type;
//   List<double> coordinates;
//
//   Location({this.type, this.coordinates});
//
//   Location.fromJson(Map<String, dynamic> json) {
//     type = json['type'];
//     coordinates = json['coordinates'].cast<double>();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['type'] = this.type;
//     data['coordinates'] = this.coordinates;
//     return data;
//   }
// }

// class PopularServices {
//   String sId;
//   String speciality;
//   String serviceId;
//   String service;
//   String serviceName;
//   String familyName;
//   String specialityIconImage;
//   String specialityIconImageApp;
//   String specialityPicture;
//
//   PopularServices(
//       {this.sId,
//         this.speciality,
//         this.serviceId,
//         this.service,
//         this.serviceName,
//         this.familyName,
//         this.specialityIconImage,
//         this.specialityIconImageApp,
//         this.specialityPicture});
//
//   PopularServices.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     speciality = json['speciality'];
//     serviceId = json['serviceId'];
//     service = json['service'];
//     serviceName = json['serviceName'];
//     familyName = json['familyName'];
//     specialityIconImage = json['specialityIconImage'];
//     specialityIconImageApp = json['specialityIconImageApp'];
//     specialityPicture = json['specialityPicture'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['speciality'] = this.speciality;
//     data['serviceId'] = this.serviceId;
//     data['service'] = this.service;
//     data['serviceName'] = this.serviceName;
//     data['familyName'] = this.familyName;
//     data['specialityIconImage'] = this.specialityIconImage;
//     data['specialityIconImageApp'] = this.specialityIconImageApp;
//     data['specialityPicture'] = this.specialityPicture;
//     return data;
//   }
// }
