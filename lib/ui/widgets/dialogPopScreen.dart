import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plunes/Utils/Constants.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/Utils/date_util.dart';
import 'package:plunes/models/solution_models/searched_doc_hospital_result.dart';
import 'package:plunes/models/solution_models/solution_model.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:plunes/ui/afterLogin/profile_screens/doc_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/hospital_profile.dart';
import 'package:plunes/ui/afterLogin/profile_screens/profile_screen.dart';

class DialogWidgets {
  static DialogWidgets? _instance;

  DialogWidgets._init();

  factory DialogWidgets() {
    if (_instance == null) {
      _instance = DialogWidgets._init();
    }
    return _instance!;
  }

  Widget buildProfileDialog(
      {Services? solutions, CatalogueData? catalogueData, BuildContext? context}) {
    return StatefulBuilder(builder: (context, newState) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        child: dialogProfileContent(context, solutions!, catalogueData),
      );
    });
  }

  Widget dialogProfileContent(
      BuildContext context, Services solutions, CatalogueData? catalogueData) {
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
        height: AppConfig.verticalBlockSize * 40,
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  child: Icon(Icons.close),
                  onTap: () => Navigator.of(context).pop(),
                  onDoubleTap: () {},
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                'Profile',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppConfig.mediumFont),
              ),
            ),

            Container(
              padding: EdgeInsets.only(top: AppConfig.verticalBlockSize * 2),
              margin: EdgeInsets.symmetric(
                  horizontal: AppConfig.horizontalBlockSize * 1),
              height: AppConfig.verticalBlockSize * 30,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (solutions.userType != null &&
                                solutions.professionalId != null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DoctorInfo(
                                          solutions.professionalId,
                                          isDoc: (solutions.userType!
                                                  .toLowerCase() ==
                                              Constants.doctor
                                                  .toString()
                                                  .toLowerCase()))));
                              // Widget route;
                              // if (solutions.userType.toLowerCase() ==
                              //     Constants.doctor.toString().toLowerCase()) {
                              //   route = DocProfile(
                              //       userId: solutions.professionalId);
                              // } else {
                              //   route = HospitalProfile(
                              //       userID: solutions.professionalId);
                              // }
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => route));
                            }
                          },
                          onDoubleTap: () {},
                          child: (solutions.imageUrl != null &&
                                  solutions.imageUrl!.isNotEmpty)
                              ? CircleAvatar(
                                  child: Container(
                                    height: AppConfig.horizontalBlockSize * 14,
                                    width: AppConfig.horizontalBlockSize * 14,
                                    child: ClipOval(
                                        child: CustomWidgets().getImageFromUrl(
                                            solutions.imageUrl,
                                            boxFit: BoxFit.fill)),
                                  ),
                                  radius: AppConfig.horizontalBlockSize * 7,
                                )
                              : CustomWidgets().getProfileIconWithName(
                                  solutions.name ?? PlunesStrings.NA, 14, 14),
                        ),
                        Padding(
                            padding: EdgeInsets.only(
                                left: AppConfig.horizontalBlockSize * 4)),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(solutions.name ?? PlunesStrings.NA,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppConfig.smallFont)),
                            Text(
                              catalogueData?.category ?? PlunesStrings.NA,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: AppConfig.smallFont),
                            ),
                            SizedBox(
                              height: AppConfig.verticalBlockSize * 1,
                            ),
                            RichText(
                                text: TextSpan(
                                    text: "Address ",
                                    style: TextStyle(
                                      fontSize: AppConfig.smallFont,
                                      color: Colors.black45,
                                      //fontWeight: FontWeight.w500
                                    ),
                                    children: [
                                  TextSpan(
                                      text:
                                          solutions.address ?? PlunesStrings.NA,
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: AppConfig.smallFont))
                                ])),
                          ],
                        )),
                      ],
                    ),
                    Divider(color: Colors.black54),
                    Text(
                      'Available Slots',
                      style: TextStyle(fontSize: AppConfig.smallFont),
                    ),
                    Container(
                        padding: const EdgeInsets.only(top: 20),
                        height: AppConfig.verticalBlockSize * 16,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            bool isAvailableSlot = true;
                            String day = DateUtil.getDayAsString(_slots[index]);
                            solutions.timeSlots!.forEach((slot) {
                              if (slot.day!
                                      .toLowerCase()
                                      .contains(day.toLowerCase()) &&
                                  slot.closed!) {
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
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 3),
                              margin: EdgeInsets.symmetric(
                                  vertical: AppConfig.verticalBlockSize * 1,
                                  horizontal:
                                      AppConfig.horizontalBlockSize * 1),
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
                                      visible: isAvailableSlot,
                                      child: Text(day)),
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
                          itemCount: _slots.length,
                        )),
                  ],
                ),
              ),
            ),
//            Positioned(
//              right: 0.0,
//              child: Align(
//                alignment: Alignment.topRight,
//                child: IconButton(
//                  icon: Icon(Icons.close),
//                  onPressed: () => Navigator.of(context).pop(),
//                ),
//              ),
//            ),
          ],
        ),
      ),
    );
  }

  Widget viewMoreContent(
    BuildContext context,
    CatalogueData catalogueData,
  ) {
    return Container(
        height: 475,
        width: 300,
        //margin: EdgeInsets.all(),
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  const Text(
                    'Details',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: ElevatedButton(
                      child: Icon(Icons.close),
                      onPressed: () => {
                        Navigator.of(context).pop(),
                      },
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 350,
                          width: 260,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                const Text('Defination:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  catalogueData.service ?? PlunesStrings.NA,
                                  style: const TextStyle(
                                    color: Colors.black38,
                                  ),
                                ),
                                const Divider(
                                  color: Colors.black45,
                                ),
                                Row(
                                  children: <Widget>[
                                    const Text(
                                      'Duration',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(catalogueData.duration ??
                                          PlunesStrings.NA,
                                      style: const TextStyle(
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.black45,
                                ),
                                Row(children: <Widget>[
                                  const Text(
                                    'Sittings:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    catalogueData.sitting ?? PlunesStrings.NA,
                                    style: const TextStyle(
                                      color: Colors.black38,
                                    ),
                                  ),
                                ]),
                                const Divider(
                                  color: Colors.black45,
                                ),
                                const Text(
                                  'Do\'s and Don\'t:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  catalogueData.dnd as String? ?? PlunesStrings.NA,
                                  style: const TextStyle(
                                    color: Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                label: const Text(
                  'Expand',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                icon: const Icon(Icons.expand_more),
              )
            ]));
  }
}
