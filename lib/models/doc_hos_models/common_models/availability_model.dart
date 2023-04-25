class AvailabilityModel {
  String? day;
  bool? closed, isSelected;
  List<String?>? slots;
  List<DaySelectionModel>? daySelectionList;

  AvailabilityModel(
      {this.day,
      this.closed,
      this.slots,
      this.isSelected,
      this.daySelectionList});

  Map<String, dynamic> toJson() {
    var json = {
      "slots": this.slots ?? [],
      "day": this.day,
      "closed": (this.slots == null || this.slots!.isEmpty) ? true : this.closed
    };
    return json;
  }
}

class DaySelectionModel {
  String? dayName;
  bool? isSelected;

  DaySelectionModel({this.isSelected, this.dayName});
}
