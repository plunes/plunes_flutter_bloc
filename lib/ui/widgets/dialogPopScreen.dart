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


Widget buildProfileDialog({
  @required final String dialogTitle,
  @required final String dialogMsg,
 }) {
    return StatefulBuilder(builder: (context, newState) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 0.0,
        //backgroundColor: Colors.transparent,
        child: dialogProfileContent(context),
        );
 });

}

 Widget dialogProfileContent(BuildContext context) {
        return Container(
       // padding: EdgeInsets.only(left: 25, right: 25),

        margin: EdgeInsets.all(20),
        child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
             Text('Profile',textAlign: TextAlign.center, 
             style: TextStyle(fontSize:20, fontWeight: FontWeight.bold),
             ),
            Container(
                padding: EdgeInsets.only(top: 18.0),
                margin: EdgeInsets.only(top: 13.0,right: 8.0),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                 SizedBox(height: 20.0,),
                 Row(
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

                      Column(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Anchal Sherawat', style:TextStyle(fontWeight: FontWeight.bold)),
                          Text('dermologist Consultain',style:TextStyle(color:Colors.black45), ),
                          Text('Address: haryana ', style:TextStyle(color:Colors.black45), 
                          )
                        ],
                      )
                   ],
                 ),
                  Divider(color:Colors.black54),

                  Text('Available Slots')
                  
                ],
                ),
            ),
            Positioned(
                right: 0.0,
                child: Align(
                alignment: Alignment.topRight, 
                child: IconButton(
                icon:Icon(Icons.close),
                 onPressed: () => {
                    Navigator.of(context).pop(),
                  }, 
               ),  
              ), 
            ),
            ],
        ),
        );
    }


