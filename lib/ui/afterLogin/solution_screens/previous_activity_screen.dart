import 'package:flutter/material.dart';
import '../../widgets/dialogPopScreen.dart';
class PreviousActivity extends StatelessWidget {
    static const routeName = '/prevActivity'; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previou Activities'),
      ),
      body: Column(
       // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RowBlock('Dentist Consultation and X-ray (Single Film)','(Procedure)', false),
          RowBlock('MRI', '(Test)', false),
           RowBlock('MRI', '(Test)',false),
          Container(
            margin: EdgeInsets.only(top:40.0),
            child:Text('Missed Nagotiation'),
          ),
            
              RowBlock('Root canal Treatment', '(Test)', true),
              RowBlock('MRI', '(Test)', true),
              Container(

                child:   RemiderText(),
              )  
        ],

      )
    );
  }
}

class RemiderText extends StatelessWidget {
  const RemiderText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      
    margin:EdgeInsets.all(15),
    child: Padding ( 
       padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(child: 
          Text('Please Make Sure You book within a short time, keeping in mind it is valid only for 1 hour',
           style: TextStyle(fontSize:17,)),
           ),
        ],
      ),
    ),
          );
  }
}

class RowBlock extends StatelessWidget {
    final String name;
    final String btnName;
    final bool isShow;
    RowBlock(this.name, this.btnName, this.isShow);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.symmetric(horizontal:20.0),
      height: 100,
      decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color:Colors.black)),
        ),
     child:Row(

       children: <Widget>[
         Container(
              width: 50.0,
              height: 50.0,
              margin: EdgeInsets.all(10),
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                      fit: BoxFit.fill,
                      image: new NetworkImage(
                          "https://i.imgur.com/BoN9kdC.png")
                  )
              )),
         Flexible(child: 
         // 'Dentist Consultation and X-ray (Single Film)'
         Text(name),
         ),
          FlatButton(
            child: Text(btnName),
            onPressed: () {
             showDialog(
            context: context,
            builder: (BuildContext context) => DialogWidgets().buildAboutDialog(dialogTitle: '', 
            dialogMsg: 'Now you can have a multiple telephonic consltaoipn & one free vist'),
          );
            },
            textColor: Theme.of(context).primaryColor,
            ),
     ],
     ),
    );
  }
}