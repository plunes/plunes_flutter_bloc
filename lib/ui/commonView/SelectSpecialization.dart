import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/Constants.dart';

class SelectSpecialization extends StatefulWidget {
  final List spec, selectedItemId, selectedItemData;
  final String from;

  SelectSpecialization(
      {Key key,
      this.spec,
      this.from,
      this.selectedItemId,
      this.selectedItemData})
      : super(key: key);

  @override
  SelectSpecializationState createState() => SelectSpecializationState();
}

class SelectSpecializationState extends State<SelectSpecialization> {
  final _searchController = TextEditingController();
  String teamName = '';
  bool icons = true;
  List<dynamic> _selectedItemId = List();
  List<dynamic> _selectedData = List();

  List specialization_filter_lists = new List();
  List<bool> select = new List();
  bool show_err_msg = false;

  @override
  void initState() {
    super.initState();
    specialization_filter_lists.addAll(widget.spec);
    _selectedItemId = widget.selectedItemId;
    _selectedData = widget.selectedItemData;
  }

  @override
  Widget build(BuildContext context) {
    final search = Card(
      elevation: 0,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, top: 15, bottom: 15, right: 30),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration.collapsed(hintText: 'Search'),
                onChanged: (text) {
                  setState(() {
                    specialization_filter_lists.clear();
                    for (int i = 0; i < widget.spec.length; i++) {
                      if (widget.spec[i]
                          .toString()
                          .toLowerCase()
                          .contains(text)) {
                        specialization_filter_lists.add(widget.spec[i]);
                      }
                    }
                    if (text.length > 0) {
                      icons = false;
                    } else {
                      icons = true;
                    }
                    print(text);
                  });
                },
              ),
            ),
          ),
          Align(
            child: Container(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _searchController.text = "";
                    icons = true;
                    specialization_filter_lists.addAll(widget.spec);
                  });
                },
                child: icons
                    ? Icon(
                        Icons.search,
                        color: Colors.grey,
                      )
                    : Icon(Icons.close),
              ),
              padding: EdgeInsets.only(right: 10, top: 18),
            ),
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );

    return CupertinoAlertDialog(
      content: Container(
        height: 400,
        child: Column(
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Expanded(
                  child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 30, right: 0, bottom: 10),
                child: Center(
                    child: Text("Specialists",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
              )),
              Container(
                margin: EdgeInsets.only(left: 10, right: 0, bottom: 10),
                width: 25,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              )
            ]),
            widget.from != null ? search : Container(),
            show_err_msg
                ? Text(
                    "could not select more than 5 specialists",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                : Text(""),
            specialization_filter_lists.length == 0
                ? Expanded(
                    child: Center(
                      child: Text(
                        "No data",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, index) {
                        int removePosition = _selectedItemId
                            .indexOf(specialization_filter_lists[index].id);
                        return FlatButton(
                          onPressed: () {
                            handleSelectionProcess(index, removePosition);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Container(
                                          child: Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, top: 8.0),
                                    child: Text(
                                      specialization_filter_lists[index]
                                          .speciality,
                                      style: TextStyle(
                                          color: _selectedItemId.indexOf(
                                                      specialization_filter_lists[
                                                              index]
                                                          .id) >
                                                  -1
                                              ? Color(0xff01d35a)
                                              : Colors.black),
                                    ),
                                  ))),
                                  widget.from == Constants.hospital
                                      ? Container(
                                          width: 20,
                                          child: Checkbox(
                                              value: _selectedItemId.indexOf(
                                                          specialization_filter_lists[
                                                                  index]
                                                              .id) >
                                                      -1
                                                  ? true
                                                  : false,
                                              onChanged: (val) {}),
                                        )
                                      : Container()
                                ],
                              ),
                              Divider(
                                height: 0.5,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: specialization_filter_lists.length,
                    ),
                  ),
          ],
        ),
      ),
      actions: [
        widget.from != null
            ? CupertinoDialogAction(
                textStyle: TextStyle(color: Color(0xff01d35a)),
                isDefaultAction: true,
                child: Text(widget.from == Constants.doctor ? 'Done' : 'Apply'),
                onPressed: () {
                  Navigator.of(context).pop({
                    'SelectedId': _selectedItemId,
                    'SelectedData': _selectedData
                  });
                },
              )
            : Container()
      ],
    );
  }

  void handleSelectionProcess(int index, int removePosition) {
    if (widget.from != null) {
      if (removePosition > -1) {
        _selectedData.remove(specialization_filter_lists[index].speciality);
        _selectedItemId.remove(specialization_filter_lists[index].id);
        show_err_msg = false;
      } else {
        if (widget.from == Constants.doctor && _selectedItemId.length > 4) {
          show_err_msg = true;
        } else {
          show_err_msg = false;
          _selectedData.add(specialization_filter_lists[index].speciality);
          _selectedItemId.add(specialization_filter_lists[index].id);
        }
      }
    } else {
      if (_selectedItemId.contains(specialization_filter_lists[index].id)) {
        _selectedData.remove(specialization_filter_lists[index].speciality);
        _selectedItemId.remove(specialization_filter_lists[index].id);
      } else {
        if (_selectedItemId.length > 0) {
          _selectedItemId.clear();
          _selectedData.clear();
        }
        _selectedData.add(specialization_filter_lists[index].speciality);
        _selectedItemId.add(specialization_filter_lists[index].id);
      }
      Navigator.of(context)
          .pop({'SelectedId': _selectedItemId, 'SelectedData': _selectedData});
    }
    setState(() {});
  }
}
