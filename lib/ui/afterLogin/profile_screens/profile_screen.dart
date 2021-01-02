import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:plunes/res/StringsFile.dart';

// ignore: must_be_immutable
class DoctorInfo extends BaseActivity {
  @override
  _DoctorInfoState createState() => _DoctorInfoState();
}

class _DoctorInfoState extends BaseState<DoctorInfo>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Widget> _tabWidgets = [
    PhotosWidget(),
    ReviewWidget(),
    AchievementWidget(),
  ];
  var _decorator = DotsDecorator(
      activeColor: PlunesColors.BLACKCOLOR,
      color: Color(CommonMethods.getColorHexFromStr("#E4E4E4")));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.getAppBar(context, plunesStrings.profile, true),
        body: SingleChildScrollView(
          child: Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CarouselSlider.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Image.network(
                          'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg',
                          width: double.infinity,
                          height: 327,
                          fit: BoxFit.fill,
                        );
                      },
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 5),
                        height: 327,
                        viewportFraction: 1.0,
                      )),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: DotsIndicator(
                      dotsCount: 2,
                      position: 0,
                      axis: Axis.horizontal,
                      decorator: _decorator,
                      onTap: (pos) {
                        // _controller.animateToPage(pos.toInt(),
                        //     curve: Curves.easeInOut,
                        //     duration: Duration(milliseconds: 300));
                        // _currentDotPosition = pos;
                        // _streamController?.add(null);
                        // return;
                      },
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.all(13),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dr. Ankit Gupta',
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Color(0xffFDCC0D)),
                            Text(
                              '4.5',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 25.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'MBBS, PG',
                      style: TextStyle(color: Color(0xff4F4F4F)),
                    ),
                    SizedBox(height: 15),
                    DottedLine(),
                    SizedBox(height: 15),
                    Text(
                      'Introduction',
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut nibh aliquam erat voluptat ut wisi enim ad minim veniam, quis exe',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    DottedLine(),
                    SizedBox(
                      height: 22,
                    ),
                    Container(
                      height: 126,
                    ),
                    SizedBox(
                      height: 39,
                    ),
                    Text(
                      'Facility have',
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Card(
                              child: Container(
                                margin: EdgeInsets.only(right: 20),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(6),
                                          bottomRight: Radius.circular(6),
                                          topLeft: Radius.circular(13),
                                          topRight: Radius.circular(13)),
                                      child: Image.network(
                                        'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                                        fit: BoxFit.fill,
                                        height: 150,
                                      ),
                                    ),
                                    Text(
                                      'covid safe',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                      topLeft: Radius.circular(13),
                                      topRight: Radius.circular(13))));
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: TabBar(
                          unselectedLabelColor: Colors.black,
                          labelColor: Colors.white,
                          controller: TabController(
                            length: _tabWidgets.length,
                            vsync: this,
                            initialIndex: _selectedIndex,
                          ),
                          indicator: new BubbleTabIndicator(
                            indicatorHeight: 40.0,
                            indicatorColor: Color(0xff01D25A),
                            tabBarIndicatorSize: TabBarIndicatorSize.tab,
                          ),
                          onTap: (i) {
                            setState(() {
                              _selectedIndex = i;
                            });
                          },
                          tabs: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                  child: Text(
                                'Photos/Videos',
                                style: TextStyle(fontSize: 14),
                              )),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                  child: Text(
                                'Review',
                                style: TextStyle(fontSize: 14),
                              )),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                  child: Text(
                                'Achievements',
                                style: TextStyle(fontSize: 14),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _tabWidgets[_selectedIndex],
                    SizedBox(
                      height: 10,
                    ),
                    DottedLine(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Time Slots',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
              Container(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Chip(
                        labelPadding: EdgeInsets.all(08),
                        backgroundColor: Colors.white,
                        label: Text(
                          '9:00 A.M.',
                        )),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 13),
                  child: DottedLine()),
              SizedBox(
                height: 25,
              ),
              Text(
                'Specialization',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              SpecialisationWidget()
            ],
          )),
        ));
  }
}

class PhotosWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),
              Text(
                'Photos',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Card(
                        child: Container(
                          margin: EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(6),
                                    bottomRight: Radius.circular(6),
                                    topLeft: Radius.circular(13),
                                    topRight: Radius.circular(13)),
                                child: Image.network(
                                  'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                                  fit: BoxFit.fill,
                                  height: 150,
                                ),
                              ),
                            ],
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13))));
                  },
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 8,
              ),
              Text(
                'Videos',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Card(
                        child: Container(
                          margin: EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(6),
                                    bottomRight: Radius.circular(6),
                                    topLeft: Radius.circular(13),
                                    topRight: Radius.circular(13)),
                                child: Image.network(
                                  'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                                  fit: BoxFit.fill,
                                  height: 150,
                                ),
                              ),
                            ],
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13))));
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ReviewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double c_width = MediaQuery.of(context).size.width * 0.8;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 8,
          ),
          Text(
            'Reviews',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(
            height: 8,
          ),
          Container(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Card(
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      width: c_width,
                      margin: EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13)),
                            child: Image.network(
                              'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                              fit: BoxFit.fill,
                              height: 150,
                              width: 100,
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                // width: c_width*0.6,
                                child: Text(
                                  'Rahul shukla',
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Color(0xff4E4E4E),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: c_width * 0.5,
                                child: Text(
                                  // '',
                                  'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut nibh aliquam erat voluptat ut wisi enim ad minim veniam, quis exe',
                                  softWrap: true,
                                  maxLines: 4,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xff4E4E4E),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                            topLeft: Radius.circular(13),
                            topRight: Radius.circular(13))));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 8,
        ),
        Text(
          'Achievements',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          height: 8,
        ),
        Container(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Card(
                  child: Container(
                    margin: EdgeInsets.only(right: 20),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(6),
                              bottomRight: Radius.circular(6),
                              topLeft: Radius.circular(13),
                              topRight: Radius.circular(13)),
                          child: Image.network(
                            'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                            fit: BoxFit.fill,
                            height: 150,
                          ),
                        ),
                      ],
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(13))));
            },
          ),
        ),
      ],
    );
  }
}

class SpecialisationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Card(
              child: Container(
                margin: EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(13)),
                      child: Image.network(
                        'https://images.pexels.com/photos/4173239/pexels-photo-4173239.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940',
                        fit: BoxFit.fill,
                        height: 150,
                      ),
                    ),
                    Text(
                      'covid safe',
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13))));
        },
      ),
    );
  }
}
