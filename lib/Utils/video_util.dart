import 'package:flutter/material.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class VideoUtil extends BaseActivity {
  String videoUrl;

  VideoUtil(this.videoUrl);

  @override
  _VideoUtilState createState() => _VideoUtilState();
}

class _VideoUtilState extends BaseState<VideoUtil> {
  VideoPlayerController _controller;
  bool _isProcessing;

  @override
  void initState() {
    _isProcessing = true;
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _isProcessing = false;
        _controller.play();
        _setState();
      });
    _controller?.setLooping(true);
    super.initState();
  }

  _setState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: widget.getAppBar(context, "Video", true),
      body: Center(
        child: (!(_isProcessing) && _controller.value.initialized)
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CustomWidgets().getProgressIndicator(),
      ),
      floatingActionButton: (!(_isProcessing) && _controller.value.initialized)
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : Container(),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
