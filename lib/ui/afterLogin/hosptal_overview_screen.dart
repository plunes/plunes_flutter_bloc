import 'package:flutter/material.dart';
import '../../Utils/custom_widgets.dart';


class Duration {

  final String name;


  Duration(this.name);

  static List<Duration> getDuration() {
    return <Duration>[
      Duration('Select'),
      Duration('Today'),
      Duration('Weekly'),
      Duration('Monthly'),
      Duration('Yearly'),
    ];
  }
}

class HospitalOverviewScreen extends StatelessWidget {
  static const routeName = '/hospitalOverview';

  Duration _selectLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title:Text('hospital OverView'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top:5, left:5, right: 5),
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Neelkanth Hospital Private Limited ', style: TextStyle(
                      fontSize: 15
                  ),),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              // padding: EdgeInsets.all(10),
              child: Card(
                margin: EdgeInsets.only(top:5, left:5, right: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical:5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      ListTile(
                        leading:CircleAvatar(),
                        title:Text('Real Time Insights', style: TextStyle(
                          fontSize:20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),),
                        isThreeLine: false,
                        subtitle:Text('Maximum time limit 10 Min', style: TextStyle(
                          fontSize:10,
                        ),),
                      ),

                      Divider(),
                      // RealTimeInsightsWIdget(),
                      RecentPatients('Saurabh Panday',
                          'is Loking for RCT',
                          'https://i.imgur.com/BoN9kdC.png'),
                      FlatButtonLinks('Kindly Update your price', 15,
                          null, 78, true),
                      Divider(color:Colors.black38),

                      ListOfPatients('10 people searching for the catalogue',
                          Colors.lightBlue[50],
                          null),
                      FlatButtonLinks('View the Details', 15,null, 78, true),
                      Divider(),
                      ListOfPatients('10 people searching for the catalogue',
                          Colors.green[50], null),
                      FlatButtonLinks('View the Details', 15, null, 78, true),
                      Divider(),
                      ListOfPatients(
                          '10 people searching for the catalogue',
                          Colors.orange[50],
                          null),
                      FlatButtonLinks('View the Details ', 15, null, 78, true),
                      Divider(),
                      ListOfPatients(
                          '10 people searching for the catalogue',
                          Colors.orange[50],
                          null),
                      FlatButtonLinks('View the Details', 15,null, 78, true),
                      Divider(),
                      ListOfPatients(
                          '10 people searching for the catalogue',
                          Colors.orange[50],
                          null),
                      FlatButtonLinks('View the Details', 15, null, 78, true),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top:5),
              width:double.infinity,
              child: Card(

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      ListTile(
                        leading:IconButton(icon: Icon(Icons.attach_money, size:40, color: Colors.green,),),
                        title:Text('Total Business', style: TextStyle(
                          fontSize:20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),),
                        trailing:  Text('add drop down here'),
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal:60, vertical: 15),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:<Widget>[
                              Column(
                                children: <Widget>[
                                  Text('\u20B9 4500', style:TextStyle(
                                    color: Colors.green,
                                    fontSize:30,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  Text('Business Earned', style:TextStyle(
                                      color: Colors.black54),)
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text('\u20B9 6424', style:TextStyle(
                                    color: Colors.yellow,
                                    fontSize:30,
                                    fontWeight: FontWeight.bold,
                                  ),),
                                  Text('Business Lost', style:TextStyle(
                                      color: Colors.black54
                                  ),),
                                ],
                              )
                            ]
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Text('Please take action real time Insights to increase your business')
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top:5),
              width:double.infinity,
              child: Card(

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      ListTile(
                        leading:IconButton(icon: Icon(Icons.attach_money, size:40, color: Colors.green,),),
                        title:Text('Actionable Insights', style: TextStyle(
                          fontSize:20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),),
                      ),
                      Divider(color: Colors.black38),
                      Container(
                          margin: EdgeInsets.only(right: 20, left:20, top:10),
                          child: Text('Please take action real time Insights to increase your business', style:TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                          ))
                      ),
                      FlatButtonLinks('Update here',15, null, 0, true),

                      Divider(color: Colors.black38),
                      Container(
                          margin: EdgeInsets.only(right: 20, left:20, top:10),
                          child: Text('Please take action real time Insights to increase your business', style:TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                          ))
                      ),
                      FlatButtonLinks('Update here',15, null, 0, true),

                      Divider(color: Colors.black38),
                      Container(
                          margin: EdgeInsets.only(right: 20, left:20, top:10),
                          child: Text('Please take action real time Insights to increase your business', style:TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                          ))
                      ),
                      FlatButtonLinks('Update here',15, null, 0, true),
                      FlatButtonLinks('View More',18, null, 0 , false),

                    ],
                  ),
                ),
              ),
            ),



          ],
        ),
      ),

    );

  }
}



class RealTimeInsightsWIdget extends StatelessWidget {
  const RealTimeInsightsWIdget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(

        ),
        Text('Real Time Insights', style: TextStyle(
          fontSize:20,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),),
        Text('Maximum time limit 10 Min', style: TextStyle(
          fontSize:10,
        ),

          overflow: TextOverflow.visible,
          softWrap: true,

        ),
      ],
    );
  }
}

class FlatButtonLinks extends StatelessWidget {
  final String linkName;
  final String onTapFunc;
  double leftMargin;
  bool isUnderline;
  double fontSize;


  FlatButtonLinks(this.linkName, this.fontSize,this.onTapFunc, this.leftMargin, this.isUnderline);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(left:leftMargin),
      child: FlatButton(
        child: Text(linkName,
          style: TextStyle(
            fontSize: fontSize,
            color:Colors.green,
            decoration: isUnderline? TextDecoration.underline : TextDecoration.none,
          ),), onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => CustomWidgets().updatePricePopUp(),
        );
      },),
    );
  }
}

class RecentPatients extends StatelessWidget {
  final String patientName;
  final String patientLookingFor;
  final String imagUrl;

  RecentPatients(this.patientName, this.patientLookingFor, this.imagUrl);
  // "https://i.imgur.com/BoN9kdC.png"
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading:CircleAvatar(
          radius: 30,
          backgroundImage: new NetworkImage(imagUrl),
        ) ,
        title:Text(patientName,style: TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),),
        subtitle: Text(patientLookingFor, style: TextStyle(
          fontSize: 16,), ),
        trailing: IconButton(icon:Icon(Icons.timelapse), onPressed: (){},)
    );
  }
}

class ListOfPatients extends StatelessWidget {
  final String patientName;
  // final String imagUrl;
  final Function onTapFun;
  final Color backGColor;

  ListOfPatients(this.patientName, this.backGColor, this.onTapFun);
  // "https://i.imgur.com/BoN9kdC.png"
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading:CircleAvatar(
          radius:30,
          backgroundColor: backGColor,
          child: Icon(Icons.person, size: 40,),
          // backgroundImage: new NetworkImage(imagUrl),
        ) ,
        title:Text(patientName, style: TextStyle(
          fontSize: 18,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),),
        trailing: IconButton(icon:Icon(Icons.timelapse), onPressed: (){
          onTapFun();
        },)
    );
  }
}





