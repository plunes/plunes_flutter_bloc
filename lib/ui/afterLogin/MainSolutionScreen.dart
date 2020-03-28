import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/Utils/CommonMethods.dart';

class MainSolutionScreen extends StatefulWidget {
  static const tag = "/main_solution";

  @override
  _MainSolutionScreenState createState() => _MainSolutionScreenState();
}

class _MainSolutionScreenState extends State<MainSolutionScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CommonMethods.globalContext = context;

    return Scaffold(backgroundColor: Colors.white, body: Container());
  }
}
