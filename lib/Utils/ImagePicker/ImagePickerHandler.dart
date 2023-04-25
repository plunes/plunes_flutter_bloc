import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:permission/permission.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:video_compress/video_compress.dart';

import './ImagePickerDialog.dart';

/*
 * Created by - Plunes Technologies.
 * Developer - Manvendra Kumar Singh
 * Description - ImagePickerHandler class is for handling the different types of image Intent i.e; Gallery Image, Video and Camera Image, video.
 */

class ImagePickerHandler {
  late ImagePickerDialog imagePicker;
  AnimationController? _controller;
  ImagePickerListener _listener;
  bool _forVideo;
  BuildContext? _context;
  MethodCallBack? methodCallBack;

  ImagePickerHandler(this._listener, this._controller, this._forVideo,
      {this.methodCallBack});

  void init() {
    _forVideo
        ? imagePicker = new ImagePickerDialog(this, _controller, true)
        : imagePicker = new ImagePickerDialog(this, _controller, false);
    imagePicker.initState();
  }

  Future<FilePickerResult?> pickFile(BuildContext context,
      {FileType? fileType}) async {
    if (_context == null) _context = context;
    if (!await _hasStoragePermission()) {
      // print("does not have storage permission");
      await Future.delayed(Duration(milliseconds: 500));
      await _requestStoragePermission();
      if (!await _hasStoragePermission()) {
        // print("denied storage permission");
        return null;
      }
    }
    // return await FilePicker.getFile(type: fileType ?? FileType.any); - commented on 2feb-2023
    return await FilePicker.platform.pickFiles(type: fileType!);
  }

  showDialog(BuildContext context) {
    if (_context == null) _context = context;
    imagePicker.getImage(context);
  }

  openCamera() async {
    imagePicker.dismissDialog();
    if (!await _hasCameraPermission()) {
      print("does not have camera permission");
      await Future.delayed(Duration(milliseconds: 500));
      await _requestCameraPermission();
      if (!await _hasCameraPermission()) {
        print("denied camera permission");
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
      print("does not have camera permission");
      await Future.delayed(Duration(milliseconds: 500));
      await _requestCameraPermission();
      if (!await _hasCameraPermission()) {
        print("denied camera permission");
        return;
      }
    }
    try {
      var image = await ImagePicker().getVideo(source: ImageSource.camera);
      if (image == null || image.path == null) {
        return;
      }
      print("VideoCameraPath: " + image.path);
      // cropVideo(image.path);
      //
      // _listener.fetchImageCallBack(File(croppedFile!.path));

      /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
      _listener.fetchImageCallBack(File(image.path));
    } catch (e) {
      print("video_crop_upload_issue:${e.toString()}");
    }
  }

  openGallery() async {
    imagePicker.dismissDialog();
    // print("exceeded 2");
    if (!await _hasStoragePermission()) {
      // print("does not have storage permission");
      await Future.delayed(Duration(milliseconds: 500));
      await _requestStoragePermission();
      if (!await _hasStoragePermission()) {
        // print("denied storage permission");
        return;
      }
    }
    // print("exceeded");
    try {
      var image = await ImagePicker().getImage(
          source: ImageSource.gallery, maxWidth: 1000, maxHeight: 1000);
      print("GalleryImagePath1: $image");

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
      // cropVideo(image.path);

      /// Comment this line if you don't want to crop an image. and Uncomment bellow line for getting image path
//    _listener.fetchImageCallBack(image);
      _listener.fetchImageCallBack(File(image.path));
    } catch (e) {}
  }

  Future<CroppedFile?> cropImage(String imageFile) async {
    var croppedFile = await ImageCropper.platform
        .cropImage(sourcePath: imageFile, maxWidth: 1080, maxHeight: 1080);
    _listener.fetchImageCallBack(File(croppedFile!.path));
    return croppedFile;
  }

  // Future<File?> cropVideo(String videoFile) async {
  //   if (this.methodCallBack != null) {
  //     this.methodCallBack!.progressCallBack();
  //   }
  //   MediaInfo mediaInfo = await (VideoCompress.compressVideo(
  //     videoFile, duration: 10, includeAudio: true,
  //     quality: VideoQuality.MediumQuality,
  //     deleteOrigin: false, // It's false by default
  //   ) as FutureOr<MediaInfo>);
  //   // print("file size is ${mediaInfo?.filesize}");
  //   // print("file duration is ${mediaInfo?.duration}");
  //   _listener.fetchImageCallBack(mediaInfo.file);
  //   return mediaInfo.file;
  // }

  Future<bool> _hasCameraPermission() async {
    bool hasCameraPermission = false;
    var status = await Permission.camera.status;
    if (status.isGranted || status.isLimited) {
      hasCameraPermission = true;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
      ].request();
      hasCameraPermission = false;
    }
    // if (Platform.isIOS) {
    //   var status = await Permission.camera.status;
    //
    //   // print("ios camera permission status $status");
    //   hasCameraPermission = (status == PermissionStatus.allow ||
    //       status == PermissionStatus.always ||
    //       status == PermissionStatus.whenInUse);
    // } else if (Platform.isAndroid) {
    //   var permissionList =
    //       await Permission.getPermissionsStatus([PermissionName.Camera]);
    //   permissionList.forEach((element) {
    //     // print(
    //     //     " ${element.permissionStatus} element.permissionName ${element.permissionName}");
    //     if (element.permissionName == PermissionName.Camera &&
    //         (element.permissionStatus == PermissionStatus.allow ||
    //             element.permissionStatus == PermissionStatus.always ||
    //             element.permissionStatus == PermissionStatus.whenInUse)) {
    //       hasCameraPermission = true;
    //     }
    //   });
    // }
    return hasCameraPermission;
  }

  Future<bool> _hasStoragePermission() async {
    bool hasStoragePermission = false;
    var status = await Permission.storage.status;

    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        var release = androidInfo.version.release!;
        print("_hasStoragePermission_release : ${release}");

        if (null != release && int.parse(release) >= 13) {
          return true;
        }
      } catch (e) {
        print("_hasStoragePermission_error : ${e.toString()}");
      }
    }

    if (status.isGranted || status.isLimited) {
      hasStoragePermission = true;
    } else if (status.isPermanentlyDenied || status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.camera,
      ].request();
      print("statuses[Permission.storage]");
      print(statuses[Permission.storage]);

      hasStoragePermission = false;
    } else {
      hasStoragePermission = false;
    }

    // commented on 2-feb-2023--------------------------------------------------------------
    // if (Platform.isIOS) {
    //   PermissionStatus status =
    //       await Permission.getSinglePermissionStatus(PermissionName.Camera);
    //   // print("ios storage permission status $status");
    //   hasStoragePermission = (status == PermissionStatus.allow ||
    //       status == PermissionStatus.always ||
    //       status == PermissionStatus.whenInUse);
    // } else if (Platform.isAndroid) {
    //   var permissionList =
    //       await Permission.getPermissionsStatus([PermissionName.Storage]);
    //   permissionList.forEach((element) {
    //     // print(
    //     //     " ${element.permissionStatus} element.permissionName ${element.permissionName}");
    //     if (element.permissionName == PermissionName.Storage &&
    //         (element.permissionStatus == PermissionStatus.allow ||
    //             element.permissionStatus == PermissionStatus.always ||
    //             element.permissionStatus == PermissionStatus.whenInUse)) {
    //       hasStoragePermission = true;
    //     }
    //   });
    // }
    return hasStoragePermission;
  }

  Future<bool> _requestStoragePermission() async {
    bool hasStoragePermission = false;
    var storageStatus = await Permission.storage.status;
    print("storageStatus:$storageStatus");

    if (storageStatus.isGranted || storageStatus.isLimited) {
      hasStoragePermission = true;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();
      hasStoragePermission = false;
    }
    return hasStoragePermission;
  }

  Future<bool> _requestCameraPermission() async {
    bool hasCameraPermission = false;
    var cameraStatus = await Permission.camera.status;

    print("cameraStatus:$cameraStatus");
    if (cameraStatus.isGranted || cameraStatus.isLimited) {
      hasCameraPermission = true;
    } else if (cameraStatus.isPermanentlyDenied || cameraStatus.isDenied) {
      print("cameraStatus_else1:$cameraStatus");

      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();
      print(statuses[Permission.camera]);
      print("cameraStatus_else2:$cameraStatus");

      hasCameraPermission = false;
    } else {
      hasCameraPermission = false;
    }
    return hasCameraPermission;
  }
}

/// ImagePickerListener is the interface for callBack of fetched image.
abstract class ImagePickerListener {
  fetchImageCallBack(var _image);
}

/// MethodCallBack is the interface for callBack of fetched image.
abstract class MethodCallBack {
  progressCallBack();
}
