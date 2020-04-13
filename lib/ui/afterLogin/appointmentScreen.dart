import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class AppointmentScreen extends StatelessWidget {
  static const routeName = '/appointment';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment'),
        backgroundColor: Colors.green,
      ),
      body:Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:<Widget>[
                  Container(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Dr. Diksha Ahuja',  style: TextStyle(fontSize:16, fontWeight: FontWeight.bold),),
                        SizedBox(height: 5),
                        Text('C9/38,Gate no 3 Clock C Ardee City Sector 52,Gurugram, haryana 122003, India',
                          overflow: TextOverflow.visible,
                          style: TextStyle(fontSize:12, color: Colors.black54),),
                        SizedBox(height: 5),
                        Text('0987654321',style: TextStyle(fontSize:15, fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    margin: EdgeInsets.only(bottom:80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        IconButton(icon: Icon(
                            Icons.location_on,size:40,
                            color:Colors.blueGrey),
                            onPressed: (){

                            }),
                      ],
                    ),
                  ),
                  Container(
                    width: 120,
                    //margin: EdgeInsets.only(bottom:40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text( DateFormat('MMM dd').format(DateTime.now()).toUpperCase(), style:TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                        Text( DateFormat('dd MMM yyyy').format(DateTime.now()),  style: TextStyle(color: Colors.black54)),
                        Text( DateFormat.jm().format(DateTime.now()).toUpperCase(),  style: TextStyle(color: Colors.black54)),

                        Container(
                          margin: EdgeInsets.only(top:20),
                          child: RaisedButton(
                            child:Text('Visit Again', style: TextStyle(color:Colors.white),),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30),
                            ),
                            onPressed:(){
                            },
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),


                ]
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical:20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    child: Text('Confirmed', style: TextStyle(fontSize:17,color: Colors.green)),
                    onPressed: () {},
                  ),
                  FlatButton(
                    child: Text('Reschedule',style: TextStyle(fontSize:17,color: Colors.black54)),
                    onPressed: () {},
                  ),
                  FlatButton(
                    child: Text('Cancel',  style: TextStyle(fontSize:17,color: Colors.red)),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal:15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Dental Braces', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text('40000 ', style: TextStyle(decoration: TextDecoration.lineThrough)),
                          Text('30000'),
                        ],
                      ),
                      Text('save 30%', style:TextStyle(color:Colors.green))
                    ],
                  ),
                ],
              ),
            ),
            Container(

              margin: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Text('Payement Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),

                  SizedBox(height: 35),
                  StepProgressIndicator(
                    totalSteps: 3,
                    currentStep: 1,
                    size: 6,
                    padding: 0,
                    customSize: (_) =>5,
                    selectedColor: Colors.green,
                    unselectedColor: Colors.grey[200],
                    customStep: (index, color, size) => color == Colors.green
                        ? Container(
                      color: color,
                      child:
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),

                    )
                        : Container(
                      color: color,
                      child: Icon(
                        Icons.check_circle_outline,
                      ),
                    ),
                  ),

                ],
              ),
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal:40, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Pay  6000', style: TextStyle(fontSize: 20, color: Colors.green,  decoration: TextDecoration.underline)),
                  SizedBox(height: 25),
                  Text('Please make sure that you pay through app for 30% discount to be valid',
                      style: TextStyle(color: Colors.black87, fontSize: 16)),
                ],
              ),
            ),


            Container(
              margin: EdgeInsets.symmetric(horizontal:15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Request Invoidce', style: TextStyle(fontSize: 18, color: Colors.black54,  decoration: TextDecoration.underline)),
                  Text('Refund', style: TextStyle(fontSize: 17, color: Colors.black54, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


