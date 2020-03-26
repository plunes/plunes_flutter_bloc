import 'dart:async';

import 'package:flutter/material.dart';

import './ImagePickerHandler.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - ImagePickerDialog class is used for open common dialog with gallery and camera option.
 */

class ImagePickerDialog extends StatelessWidget {
  ImagePickerHandler _listener;
  AnimationController _controller;
  BuildContext context;
  bool _forVideo;

  ImagePickerDialog(this._listener, this._controller, this._forVideo);

  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  getImage(BuildContext context) {
    if (_controller == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
      return;
    }
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => new SlideTransition(
        position: _drawerDetailsPosition,
        child: new FadeTransition(
          opacity: new ReverseAnimation(_drawerContentsOpacity),
          child: this,
        ),
      ),
    );
  }

  void dispose() {
    _controller.dispose();
  }

  startTime() async {
    return new Timer(Duration(milliseconds: 300), navigationPage);
  }

  void navigationPage() {
    Navigator.pop(context);
  }

  dismissDialog() {
    _controller.reverse();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return GestureDetector(
      onTap: () => dismissDialog(),
      child: Material(
          type: MaterialType.transparency,
          child: new Opacity(
            opacity: 1.0,
            child: Container(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: new Wrap(
                      children: <Widget>[
                        new ListTile(
                          leading: new Icon(Icons.camera),
                          title: new Text('Camera'),
                          onTap: () => _forVideo
                              ? _listener.openCameraForVideo()
                              : _listener.openCamera(),
                        ),
                        new ListTile(
                          leading: new Icon(Icons.image),
                          title: new Text('Gallery'),
                          onTap: () => _forVideo
                              ? _listener.openGalleryForVideo()
                              : _listener.openGallery(),
                        ),
                      ],
                    ),
                  ),
                ])),
          )),
    );
  }
}
