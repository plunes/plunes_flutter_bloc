import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/StringsFile.dart';
import 'package:shimmer/shimmer.dart';

class AvailabilitySelectionScreen extends BaseActivity {
  static const tag = '/availabilitySelectionScreen';
  final String url;

  AvailabilitySelectionScreen({Key key, this.url}) : super(key: key);

  @override
  _AvailabilitySelectionScreenState createState() =>
      _AvailabilitySelectionScreenState();
}

class _AvailabilitySelectionScreenState
    extends State<AvailabilitySelectionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var globalHeight, globalWidth;

  String url;
  String user_token = "";

  bool progress = true;

  List<String> check = new List();
  List<String> from_1 = new List();
  List<String> from_2 = new List();
  List<String> to_1 = new List();
  List<String> to_2 = new List();
  List timeslots_ = new List();

  List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<String> days_name = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  Future<Null> _selectdata(String check, int position, String time) async {
    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1].substring(0, 2)));

    final TimeOfDay picker = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child,
        );
      },
    );

    if (picker != null) {
      setState(() {
        if (check == 'form1') {
          from_1[position] = picker.format(context);
        } else if (check == 'form2') {
          from_2[position] = picker.format(context);
        } else if (check == 'to1') {
          to_1[position] = picker.format(context);
        } else if (check == 'to2') {
          if (position == 0) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (
                BuildContext context,
              ) =>
                  _confirmation(context),
            ).then((text) {
              setState(() {
                if (text == "Done") {
                  for (int i = 0; i < days.length; i++) {
                    from_1[i] = from_1[0];
                    from_2[i] = from_2[0];
                    to_1[i] = to_1[0];
                    to_2[i] = to_2[0];
                  }
                }
              });
            });
          }
          to_2[position] = picker.format(context);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void get_slots() async {
    check.clear();
    from_1.clear();
    from_2.clear();
    to_1.clear();
    to_2.clear();

/*

    GettimeSlots gettimeSlots = await get_time_slots(user_token, url).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error);
      setState(() {
        progress = false;
      });
    });
*/

    setState(() {
      progress = false;
/*      if(gettimeSlots.success){


        if(gettimeSlots.fields.length == 0){
          for(int i =0; i< 7; i++){
            check.add("false");
            from_1.add("00:00");
            from_2.add("00:00");
            to_1.add("00:00");
            to_2.add("00:00");
          }
        }else{

          for(int i =0; i< gettimeSlots.fields.length; i++){
            from_1.add(gettimeSlots.fields[i].slots[0].toString().split("-")[0]);
            to_1.add(gettimeSlots.fields[i].slots[0].toString().split("-")[1]);
            check.add(gettimeSlots.fields[i].closed);
            from_2.add(gettimeSlots.fields[i].slots[1].toString().split("-")[0]);
            to_2.add(gettimeSlots.fields[i].slots[1].toString().split("-")[1]);
          }
        }

      }else{
        config.Config.showInSnackBar(
            _scaffoldKey, gettimeSlots.message, Colors.red);

      }*/
    });
  }

  void addslot() async {
    setState(() {
      progress = true;
    });

    for (int i = 0; i < 7; i++) {
      timeslots_.add({
        "slots": [
          from_1[i] + "-" + to_1[i],
          from_2[i] + "-" + to_2[i],
        ],
        "day": days_name[i],
        "closed": check[i]
      });
    }

    var body;
    var data;
    List doctors = new List();

    if (url.contains("doctors")) {
      List doctor_id = url.split("/");

      body = {"doctorId": doctor_id[6], "timeSlots": timeslots_};

      doctors.add(body);
      data = {"doctors": doctors};
    } else {
      data = {"timeSlots": timeslots_};
    }

    print(data);

    /* TimeSlotsPost timeSlotsPost = await set_time_slots(data, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      progress = false;
    });*/
/*

      setState(() {
        progress = false;
        if (timeSlotsPost.success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (
              BuildContext context,
            ) =>
                _popup_saved(context),
          );

        }else{
          config.Config.showInSnackBar(_scaffoldKey, timeSlotsPost.message, Colors.red);
        }

      });
*/
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;
    globalHeight = MediaQuery.of(context).size.height;
    globalWidth = MediaQuery.of(context).size.width;

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        "My Availability",
        style: TextStyle(color: Colors.black),
      ),
    );

    final header = Container(
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Center(
                child: Text(
              "All",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ),
          Expanded(
            flex: 2,
            child: Center(
                child: Text("From - To",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Expanded(
            flex: 2,
            child: Center(
                child: Text("From - To",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Expanded(
            flex: 1,
            child: Center(
                child: Text("Closed",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );

    final list_days = Expanded(
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color(0xffefefef)),
                      child: Center(
                        child: Text(days[index]),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: () {
                            _selectdata("form1", index, from_1[index]);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border:
                                    Border.all(width: 0.5, color: Colors.grey)),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                from_1[index],
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: () {
                            _selectdata("to1", index, to_1[index]);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border:
                                    Border.all(width: 0.5, color: Colors.grey)),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                to_1[index],
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: () {
                            _selectdata("form2", index, from_2[index]);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border:
                                    Border.all(width: 0.5, color: Colors.grey)),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                from_2[index],
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          onTap: () {
                            _selectdata("to2", index, to_2[index]);
                          },
                          child: Container(
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                border:
                                    Border.all(width: 0.5, color: Colors.grey)),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                to_2[index],
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Center(
                        child: Theme(
                      data: Theme.of(context).copyWith(
                        unselectedWidgetColor: Colors.grey,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        onTap: () {
                          setState(() {
                            if (check[index] == 'true') {
                              check[index] = 'false';
                            } else {
                              check[index] = 'true';
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            child: check[index] == 'true'
                                ? Image.asset(
                                    'assets/images/bid/check.png',
                                    height: 20,
                                    width: 20,
                                  )
                                : Image.asset(
                                    'assets/images/bid/uncheck.png',
                                    height: 20,
                                    width: 20,
                                  ),
                          ),
                        ),
                      ),
                    ))),
              ],
            ),
          );
        },
        itemCount: 7,
      ),
    );

    final submit = Container(
      margin: EdgeInsets.only(bottom: 20),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        onTap: addslot,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Color(0xff01d35a)),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    final loading = Expanded(
        child: ListView.builder(
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
            baseColor: Color(0xffF5F5F5),
            highlightColor: Color(0xffFAFAFA),
            child: Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Color(0xffefefef)),
                        child: Center(
                          child: Text(""),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "00:00",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            height: 25,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.grey),
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                            child: Image.asset('assets/images/bid/check.png',
                                height: 20, width: 20)),
                      ))),
                ],
              ),
            ));
      },
      itemCount: 7,
    ));

    final form = Container(
        child: Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 5, bottom: 10),
      child: Column(
        children: <Widget>[header, progress ? loading : list_days, submit],
      ),
    ));

    return Scaffold(
        appBar: widget.getAppBar(context, plunesStrings.availability, true),
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: form);
  }

  Widget _confirmation(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Repeat'),
      content: new Container(
        child: Column(
          children: <Widget>[
            Text("Repeat this slot in whole week"),
            SizedBox(
              height: 20,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop("Done");
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Yes",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Color(0xff01d35a),
                            border:
                                Border.all(width: 1, color: Color(0xff01d35a))),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("No"),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(width: 1, color: Colors.grey)),
                    ),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
