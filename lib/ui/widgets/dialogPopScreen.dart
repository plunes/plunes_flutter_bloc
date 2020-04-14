import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
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
    return Material(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
                              child: CustomWidgets().getImageFromUrl(solutions.imageUrl,
                                  boxFit: BoxFit.fill)),
                        ),
                        radius: AppConfig.horizontalBlockSize * 7,
                      ),
                      Padding(
                          padding:
                          EdgeInsets.only(left: AppConfig.horizontalBlockSize * 2)),
                      Expanded(
                        child:Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(solutions.name ?? PlunesStrings.NA,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            catalogueData.category ?? PlunesStrings.NA,
                            style: TextStyle(color: Colors.black45),
                          ),

                          Text( solutions.address ??
                            PlunesStrings.NA,
                            style: TextStyle(color: Colors.black45),
                          )

                        ],
                      )
                      ),
                    ],
                  ),
                  Divider(color: Colors.black54),
                  Text('Available Slots'),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: DatePicker(
                      DateTime.now(), initialSelectedDate: DateTime.now(),
                      selectionColor: Colors.green,
//                      selectedTextColor: Colors.white,
                      onDateChange: (date) {
                        // // New date selected
                        // setState(() {
                        //   _selectedValue = date;
                        // });
                      },
                    ),
                  ),
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
