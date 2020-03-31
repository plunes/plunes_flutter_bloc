import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

class UtilityNetItemAdapter extends BaseActivity {

  var from, globalWidth, globalHeight;

  UtilityNetItemAdapter(this.from, this.globalWidth, this.globalHeight);

  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<UtilityNetItemAdapter> {
  BuildContext screenContext;

  @override
  Widget build(BuildContext context) {
    screenContext = context;
    return  Container(
      height: 100,
      child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: 5/*utilityNetList.length > 4? 4: utilityNetList.length*/,
          itemBuilder: (context, index) {
            return getItemRowView(index);
          }),);
  }

  Widget getItemRowView(int index) {
    return Container(
        width: 70,
        height: 70,
        margin: EdgeInsets.only(right:5),
        child: Column(children: <Widget>[
          InkWell(onTap: (){},child: Container(
              alignment: Alignment.center,
              width: 50,
              height: 50,
              child: index == 4? Icon(
                Icons.more_horiz,
                color: Colors.grey,
                size: 30.0,
              ): widget.getAssetIconWidget('assets/default_img.png', 60, 60, BoxFit.contain), decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.all(Radius.circular(30),))),
          ),
          widget.getSpacer(0.0, 10),
          Expanded(child: widget.createTextViews(index == 4?plunesStrings.more:'Name shdj scvsdsdc dshgsdsd scscs', 10 , colorsFile.lightGrey2, TextAlign.center, FontWeight.w100)
            ,)
        ],
        ));
  }
}
