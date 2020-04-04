import 'package:flutter/material.dart';

class DialogWidgets{
  static DialogWidgets _instance;
  DialogWidgets._init();

  factory DialogWidgets(){
    if(_instance == null){
      _instance = DialogWidgets._init();
    }
    return _instance;
  }


Widget buildAboutDialog({
  @required final String dialogTitle,
  @required final String dialogMsg,
 }) {
    return StatefulBuilder(builder: (context, newState) {
    return new AlertDialog(
      
      title: Text(dialogTitle),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
          child:Text(dialogMsg),
          )
        ],
      ),
      actions: <Widget>[
       // AddButton(null,'Continue',100),
        new RaisedButton(
          onPressed: () => {
            Navigator.of(context).pop(),
          }),
      ],
    );
}
);
 }
}