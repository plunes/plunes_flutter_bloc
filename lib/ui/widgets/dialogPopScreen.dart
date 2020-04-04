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
    return AlertDialog(
        contentPadding: EdgeInsets.only(left: 25, right: 25),
         shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),

        title: Text(dialogTitle,style: TextStyle(),
        textAlign: TextAlign.center, 
        ),
        content: Container(
          margin: EdgeInsets.symmetric(vertical:20),
          height:300,
          width: 300,
         child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
               children: <Widget>[
                 
                //  SizedBox(
                //       height: 0,
                //     ),
                 
                  Text( 'Defination:', style: TextStyle(fontWeight: FontWeight.bold),),
                  Text( 'Dermologist Consultation' , style: TextStyle(
                     color: Colors.black38,
                  ),),

                    Divider(
                         color: Colors.black45,
                       ),
                   Text( 'Duration', style: TextStyle(fontWeight: FontWeight.bold),),
                    Text( 'Space for text' , style: TextStyle(
                     color: Colors.black45,
                  ),),

                       Divider(
                         color: Colors.black45,
                       ),

                    Text( 'Sittings:', style: TextStyle(fontWeight: FontWeight.bold),),
                     Text( '2' , style: TextStyle(
                     color: Colors.black38,
                  ),),
                  
                  Divider(
                         color: Colors.black45,
                       ),  

                    Text( 'Do\'s and Don\'t:', style: TextStyle(fontWeight: FontWeight.bold),),
                    Text( '1.Dermologist Consultation, Dermologist Consultation, Dermologist Consultation' , style: TextStyle(
                     color: Colors.black38,
                   ),),
                   Text( '1.Dermologist Consultation, Dermologist Consultation, Dermologist Consultation' , style: TextStyle(
                     color: Colors.black38,
                  ),),
                   Text( '1.Dermologist Consultation, Dermologist Consultation, Dermologist Consultation' , style: TextStyle(
                     color: Colors.black38,
                  ),),
               
              ],
            ),
          ),
        ),
        
        actions: <Widget>[
          Text('Expand', style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,),
          new IconButton(
             alignment: Alignment.center,
             icon:Icon(Icons.expand_more),
             onPressed: () => {
                Navigator.of(context).pop(),
             }, 
           ),
        ],


      );
});
}
}
