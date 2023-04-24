import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class YoutubePlayerProvider extends BaseActivity {
  final String? videoLink, title;

  YoutubePlayerProvider(this.videoLink, {this.title});

  @override
  _YoutubePlayerProviderState createState() => _YoutubePlayerProviderState();
}

class _YoutubePlayerProviderState extends State<YoutubePlayerProvider> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  String? _videoId;
  YoutubePlayerController? _controller;
  Key _key = Key("ourKey");

  @override
  void initState() {
    _videoId = YoutubePlayer.convertUrlToId(widget.videoLink!);
    _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: YoutubePlayerFlags(loop: false, autoPlay: true));
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _portraitUp();
        return true;
      },
      child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            key: scaffoldKey,
            appBar: widget.getAppBar(
                context, widget.title ?? "App tutorial", true,
                func: () => _portraitUp()) as PreferredSizeWidget?,
            body: _getPlayer(),
          )),
    );
  }

  Widget _getPlayer() {
    return Container(
      color: Colors.black12.withOpacity(0.7),
      child: Align(
        alignment: Alignment.center,
        child: FittedBox(
            fit: BoxFit.fill,
            child: Container(
              child: YoutubePlayerBuilder(
                player: YoutubePlayer(
                  key: _key,
                  controller: _controller!,
                  onEnded: (data) {
                    _showMessage();
                    return;
                  },
                  actionsPadding: EdgeInsets.all(8.0),
                ),
                builder: (context, player) {
                  return Column(
                    children: [
                      player,
                    ],
                  );
                },
              ),
            )),
      ),
    );
  }

  void _showMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return CustomWidgets().getInformativePopup(
              message: "Thanks for watching!", globalKey: scaffoldKey);
        }).then((value) async {
      await _portraitUp();
      Navigator.pop(context);
    });
  }

  _portraitUp() async {
    return await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp]);
  }
}
