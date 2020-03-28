import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import './ImagePickerDialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - ImagePickerHandler class is for handling the different types of image Intent i.e; Gallery Image, Video and Camera Image, video.
 */

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;
  bool _forVideo;

  ImagePickerHandler(this._listener, this._controller, this._forVideo);

  void init() {
    _forVideo
        ? imagePicker = new ImagePickerDialog(this, _controller, true)
        : imagePicker = new ImagePickerDialog(this, _controller, false);
    imagePicker.initState();
  }

  showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }

  openCamera() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 1000, maxHeight: 1000);
    print("cameraImagePath: " + image.path);
    cropImage(image);

    /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
//    _listener.fetchImageCallBack(image);
  }

  openCameraForVideo() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickVideo(source: ImageSource.camera);
    print("VideoCameraPath: " + image.path);
    cropImage(image);

    /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
//    _listener.fetchImageCallBack(image);
  }

  openGallery() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000);
    print("GalleryImagePath: " + image.path);
    cropImage(image);

    /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
    //    _listener.fetchImageCallBack(image);
  }

  openGalleryForVideo() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickVideo(source: ImageSource.gallery);
    print("VideoGalleryPath: " + image.path);
    cropImage(image);

    /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
//    _listener.fetchImageCallBack(image);
  }

  Future<File> cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path, maxWidth: 1080, maxHeight: 1080);
    _listener.fetchImageCallBack(croppedFile);
    return croppedFile;
  }
}

/// ImagePickerListener is the interface for callBack of fetched image.
abstract class ImagePickerListener {
  fetchImageCallBack(File _image);
}
