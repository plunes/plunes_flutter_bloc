import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:intl/intl.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/models/solution_models/solution_model.dart';

class DialogWidgets {
  static DialogWidgets _instance;

  DialogWidgets._init();

  factory DialogWidgets() {
    if (_instance == null) {
      _instance = DialogWidgets._init();
    }
    return _instance;
  }

  Widget buildProfileDialog({
    Services solutions,
    CatalogueData catalogueData,
  }) {
    return StatefulBuilder(builder: (context, newState) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        child: dialogProfileContent(context, solutions, catalogueData),
      );
    });
  }

  Widget dialogProfileContent(
      BuildContext context, Services solutions, CatalogueData catalogueData) {
    List<DateTime> _slots = [];
    var now = DateTime.now();
    for (int index = 0; index < 100; index++) {
      _slots.add(DateTime(now.year, now.month, now.day + index));
    }
    var monthFormat = DateFormat.MMM();
    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      child: Container(
        margin: EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: EdgeInsets.only(top: 18.0),
              margin: EdgeInsets.only(top: 13.0, right: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        child: Container(
                          height: AppConfig.horizontalBlockSize * 14,
                          width: AppConfig.horizontalBlockSize * 14,
                          child: ClipOval(
                              child: CustomWidgets().getImageFromUrl(
                                  solutions.imageUrl,
                                  boxFit: BoxFit.fill)),
                        ),
                        radius: AppConfig.horizontalBlockSize * 7,
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: AppConfig.horizontalBlockSize * 2)),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(solutions.name ?? PlunesStrings.NA,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            catalogueData.category ?? PlunesStrings.NA,
                            style: TextStyle(color: Colors.black45),
                          ),
                          Text(
                            solutions.address ?? PlunesStrings.NA,
                            style: TextStyle(color: Colors.black45),
                          )
                        ],
                      )),
                    ],
                  ),
                  Divider(color: Colors.black54),
                  Text('Available Slots'),
                  Container(
                      padding: const EdgeInsets.only(top: 30),
                      height: AppConfig.verticalBlockSize * 14,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          bool isAvailableSlot = true;
                          String day = DateUtil.getDayAsString(_slots[index]);
                          solutions.timeSlots.forEach((slot) {
                            if (slot.day
                                    .toLowerCase()
                                    .contains(day.toLowerCase()) &&
                                slot.closed) {
                              isAvailableSlot = false;
                            }
                          });
                          return Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(8.0),
                                color: isAvailableSlot
                                    ? PlunesColors.LIGHTGREYCOLOR
                                    : Colors.red),
                            padding: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 1,
                                horizontal: AppConfig.horizontalBlockSize * 3),
                            margin: EdgeInsets.symmetric(
                                vertical: AppConfig.verticalBlockSize * 1,
                                horizontal: AppConfig.horizontalBlockSize * 1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Visibility(
                                    visible: isAvailableSlot,
                                    child: Text(
                                        monthFormat.format(_slots[index]))),
                                Visibility(
                                  visible: isAvailableSlot,
                                  child: Text(
                                    _slots[index].day.toString(),
                                    style: TextStyle(
                                        fontSize: AppConfig.mediumFont),
                                  ),
                                ),
                                Visibility(
                                    visible: isAvailableSlot, child: Text(day)),
                                Visibility(
                                    visible: !isAvailableSlot,
                                    child: Text(
                                      PlunesStrings.closed,
                                      style: TextStyle(
                                          color: PlunesColors.WHITECOLOR),
                                    )),
                              ],
                            ),
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      )),
                ],
              ),
            ),
            Positioned(
              right: 0.0,
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
