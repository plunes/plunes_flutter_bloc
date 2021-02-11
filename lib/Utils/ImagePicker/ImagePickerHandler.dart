import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission/permission.dart';
import 'package:plunes/Utils/permissionUtil.dart';
import './ImagePickerDialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:video_compress/video_compress.dart';

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
  BuildContext _context;

  ImagePickerHandler(this._listener, this._controller, this._forVideo);

  void init() {
    _forVideo
        ? imagePicker = new ImagePickerDialog(this, _controller, true)
        : imagePicker = new ImagePickerDialog(this, _controller, false);
    imagePicker.initState();
  }

  showDialog(BuildContext context) {
    if (_context == null) _context = context;
    imagePicker.getImage(context);
  }

  openCamera() async {
    imagePicker.dismissDialog();
    if (!await _hasCameraPermission()) {
      // print("does not have camera permission");
      await Future.delayed(Duration(milliseconds: 500));
      await _requestCameraPermission();
      if (!await _hasCameraPermission()) {
        // print("denied camera permission");
        return;
      }
    }
    try {
      var image = await ImagePicker().getImage(
          source: ImageSource.camera, maxWidth: 1000, maxHeight: 1000);
      if (image == null || image.path == null) {
        return;
      }
      print("cameraImagePath: " + image.path);
      cropImage(image.path);

      /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
//    _listener.fetchImageCallBack(image);
    } catch (e) {
      print("error openCamera ${e.toString()}");
    }
  }

  openCameraForVideo() async {
    imagePicker.dismissDialog();
    if (!await _hasCameraPermission()) {
      // print("does not have camera permission");
      await Future.delayed(Duration(milliseconds: 500));
      await _requestCameraPermission();
      if (!await _hasCameraPermission()) {
        // print("denied camera permission");
        return;
      }
    }
    try {
      var image = await ImagePicker().getVideo(source: ImageSource.camera);
      if (image == null || image.path == null) {
        return;
      }
      // print("VideoCameraPath: " + image.path);
      cropVideo(image.path);

      /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
//    _listener.fetchImageCallBack(image);
    } catch (e) {}
  }

  openGallery() async {
    imagePicker.dismissDialog();
    if (!await _hasStoragePermission()) {
      // print("does not have storage permission");
      await Future.delayed(Duration(milliseconds: 500));
      await _requestStoragePermission();
      if (!await _hasStoragePermission()) {
        // print("denied storage permission");
        return;
      }
    }
    try {
      var image = await ImagePicker().getImage(
          source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000);
      if (image == null || image.path == null) {
        return;
      }
      print("GalleryImagePath: " + image.path);
      cropImage(image.path);

      /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
      //    _listener.fetchImageCallBack(image);
    } catch (e) {
      print("error openGallery ${e.toString()}");
    }
  }

  openGalleryForVideo() async {
    imagePicker.dismissDialog();
    if (!await _hasStoragePermission()) {
      // print("does not have storage permission");
      await Future.delayed(Duration(milliseconds: 500));
      await _requestStoragePermission();
      if (!await _hasStoragePermission()) {
        // print("denied storage permission");
        return;
      }
    }
    try {
      var image = await ImagePicker().getVideo(source: ImageSource.gallery);
      if (image == null || image.path == null) {
        return;
      }
      print("VideoGalleryPath: " + image.path);
      cropVideo(image.path);

      /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
//    _listener.fetchImageCallBack(image);
    } catch (e) {}
  }

  Future<File> cropImage(String imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile, maxWidth: 1080, maxHeight: 1080);
    _listener.fetchImageCallBack(croppedFile);
    return croppedFile;
  }

  Future<File> cropVideo(String videoFile) async {
    MediaInfo mediaInfo = await VideoCompress.compressVideo(
      videoFile, duration: 10, includeAudio: true,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false, // It's false by default
    );
    _listener.fetchImageCallBack(mediaInfo.file);
    return mediaInfo.file;
  }

  Future<bool> _hasCameraPermission() async {
    bool hasCameraPermission = false;
    if (Platform.isIOS) {
      PermissionStatus status =
          await Permission.getSinglePermissionStatus(PermissionName.Camera);
      // print("ios camera permission status $status");
      hasCameraPermission = (status == PermissionStatus.allow ||
          status == PermissionStatus.always ||
          status == PermissionStatus.whenInUse);
    } else if (Platform.isAndroid) {
      var permissionList =
          await Permission.getPermissionsStatus([PermissionName.Camera]);
      permissionList.forEach((element) {
        // print(
        //     " ${element.permissionStatus} element.permissionName ${element.permissionName}");
        if (element.permissionName == PermissionName.Camera &&
            (element.permissionStatus == PermissionStatus.allow ||
                element.permissionStatus == PermissionStatus.always ||
                element.permissionStatus == PermissionStatus.whenInUse)) {
          hasCameraPermission = true;
        }
      });
    }
    return hasCameraPermission;
  }

  Future<bool> _hasStoragePermission() async {
    bool hasStoragePermission = false;
    if (Platform.isIOS) {
      PermissionStatus status =
          await Permission.getSinglePermissionStatus(PermissionName.Storage);
      // print("ios storage permission status $status");
      hasStoragePermission = (status == PermissionStatus.allow ||
          status == PermissionStatus.always ||
          status == PermissionStatus.whenInUse);
    } else if (Platform.isAndroid) {
      var permissionList =
          await Permission.getPermissionsStatus([PermissionName.Storage]);
      permissionList.forEach((element) {
        // print(
        //     " ${element.permissionStatus} element.permissionName ${element.permissionName}");
        if (element.permissionName == PermissionName.Storage &&
            (element.permissionStatus == PermissionStatus.allow ||
                element.permissionStatus == PermissionStatus.always ||
                element.permissionStatus == PermissionStatus.whenInUse)) {
          hasStoragePermission = true;
        }
      });
    }
    return hasStoragePermission;
  }

  Future<bool> _requestStoragePermission() {
    return PermissionUtil.requestSpecificPermission(PermissionName.Storage,
        context: _context);
  }

  Future<bool> _requestCameraPermission() {
    return PermissionUtil.requestSpecificPermission(PermissionName.Camera,
        context: _context);
  }
}

/// ImagePickerListener is the interface for callBack of fetched image.
abstract class ImagePickerListener {
  fetchImageCallBack(File _image);
}
