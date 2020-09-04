import 'package:flutter/material.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class YoutubePlayerProvider extends BaseActivity {
  final String videoLink;

  YoutubePlayerProvider(this.videoLink);

  @override
  _YoutubePlayerProviderState createState() => _YoutubePlayerProviderState();
}

class _YoutubePlayerProviderState extends BaseState<YoutubePlayerProvider> {
  String _videoId;
  YoutubePlayerController _controller;
  Key _key = Key("ourKey");

  @override
  void initState() {
    _videoId = YoutubePlayer.convertUrlToId(widget.videoLink);
    _controller = YoutubePlayerController(
        initialVideoId: _videoId,
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
    return SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar: widget.getAppBar(context, "App tutorial", true),
          body: _getPlayer(),
        ));
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
                  controller: _controller,
                  onEnded: (data) {
                    _showMessage();
                    return;
                  },
                  actionsPadding: EdgeInsets.all(8.0),
                  bottomActions: <Widget>[
                    const SizedBox(width: 14.0),
                    CurrentPosition(),
                    const SizedBox(width: 8.0),
                    Flexible(
                      child: ProgressBar(
                        isExpanded: false,
                        colors: ProgressBarColors(
                            backgroundColor: PlunesColors.GREENCOLOR,
                            bufferedColor: PlunesColors.GREENCOLOR,
                            handleColor: PlunesColors.GREENCOLOR,
                            playedColor: PlunesColors.GREENCOLOR),
                      ),
                    ),
                    RemainingDuration(),
                    const PlaybackSpeedButton(),
                  ],
                ),
                builder: (context, player) {
                  return player;
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
        }).then((value) {
      Navigator.pop(context);
    });
  }
}
