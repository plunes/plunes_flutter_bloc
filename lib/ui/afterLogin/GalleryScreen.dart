// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:plunes/Utils/app_config.dart';
import 'package:plunes/Utils/custom_widgets.dart';
import 'package:plunes/base/BaseActivity.dart';
import 'package:plunes/res/ColorsFile.dart';

enum GridDemoTileStyle { imageOnly, oneLine, twoLine }

typedef BannerTapCallback = void Function(Photo photo);

const double _kMinFlingVelocity = 800.0;

class GalleryScreen extends BaseActivity {
  static const String tag = '/gallery-screen';

//  GalleryScreen({ Key key }) : super(key: key);

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  GridDemoTileStyle _tileStyle = GridDemoTileStyle.imageOnly;

  List<Photo> photos = <Photo>[
    Photo(
      assetName: 'assets/images/achievments/gradient/2.jpg',
      title: 'Chennai',
      caption: 'Flower Market',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/3.jpg',
      title: 'Tanjore',
      caption: 'Bronze Works',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/4.jpg',
      title: 'Tanjore',
      caption: 'Market',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/5.jpg',
      title: 'Tanjore',
      caption: 'Thanjavur Temple',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/6.jpg',
      title: 'Tanjore',
      caption: 'Thanjavur Temple',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/8.jpg',
      title: 'Pondicherry',
      caption: 'Salt Farm',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/9.jpg',
      title: 'Chennai',
      caption: 'Scooters',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/10.jpg',
      title: 'Chettinad',
      caption: 'Silk Maker',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/11.jpg',
      title: 'Chettinad',
      caption: 'Lunch Prep',
    ),
    Photo(
      assetName: 'assets/images/achievments/gradient/1.jpg',
      title: 'Tanjore',
      caption: 'Market',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: widget.getAppBar(context, '', true),
      body: Column(
        children: <Widget>[
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: GridView.count(
                crossAxisCount: (orientation == Orientation.portrait) ? 3 : 3,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                padding: const EdgeInsets.all(4.0),
                childAspectRatio:
                    (orientation == Orientation.portrait) ? 1.0 : 1.3,
                children: photos.map<Widget>((Photo photo) {
                  return GridPhotoItem(
                    photo: photo,
                    tileStyle: _tileStyle,
                    onBannerTap: (Photo photo) {
                      setState(() {
                        photo.isFavorite = !photo.isFavorite;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Photo {
  Photo({
    this.assetName,
    this.title,
    this.caption,
    this.isFavorite = false,
  });

  final String assetName;
  final String title;
  final String caption;

  bool isFavorite;

  String get tag => assetName; // Assuming that all asset names are unique.

  bool get isValid =>
      assetName != null &&
      title != null &&
      caption != null &&
      isFavorite != null;
}

class GridPhotoViewer extends StatefulWidget {
  const GridPhotoViewer({Key key, this.photo}) : super(key: key);

  final Photo photo;

  @override
  _GridPhotoViewerState createState() => _GridPhotoViewerState();
}

class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text),
    );
  }
}

class _GridPhotoViewerState extends State<GridPhotoViewer>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The maximum offset value is 0,0. If the size of this renderer's box is w,h
  /// then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = Offset(size.width, size.height) * (1.0 - _scale);
    return Offset(
        offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;

      /// The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);

      /// Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = _controller.drive(Tween<Offset>(
      begin: _offset,
      end: _clampOffset(_offset + direction * distance),
    ));
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleOnScaleEnd,
      child: ClipRect(
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: widget.photo.assetName.contains('http')
              ? CustomWidgets().getImageFromUrl(
                  widget.photo.assetName,
                  boxFit: BoxFit.contain,
                )
              : Image.asset(
                  widget.photo.assetName,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}

class GridPhotoItem extends StatelessWidget {
  GridPhotoItem({
    Key key,
    @required this.photo,
    @required this.tileStyle,
    @required this.onBannerTap,
  })  : assert(photo != null && photo.isValid),
        assert(tileStyle != null),
        assert(onBannerTap != null),
        super(key: key);

  final Photo photo;
  final GridDemoTileStyle tileStyle;
  final BannerTapCallback
      onBannerTap; // User taps on the photo's header or footer.

  void showPhoto(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(/*photo.title*/ ''),
        ),
        body: SizedBox.expand(
          child: Hero(
            tag: photo.tag,
            child: GridPhotoViewer(photo: photo),
          ),
        ),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = photo.isFavorite ? Icons.star : Icons.star_border;

    final Widget image = GestureDetector(
      onTap: () {
        showPhoto(context);
      },
      child: Hero(
          key: Key(photo.assetName),
          tag: photo.tag,
          child: Stack(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 3),
                  child: Card(
                      elevation: 5,
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.asset(
                            photo.assetName,
                            fit: BoxFit.cover,
                          ),
                        ],
                      ))),
            ],
          )),
    );

    switch (tileStyle) {
      case GridDemoTileStyle.imageOnly:
        return image;
      case GridDemoTileStyle.oneLine:
        return GridTile(
          header: GestureDetector(
            onTap: () {
              onBannerTap(photo);
            },
            child: GridTileBar(
              title: _GridTitleText(photo.title),
              backgroundColor: Colors.black45,
              leading: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          child: image,
        );

      case GridDemoTileStyle.twoLine:
        return GridTile(
          footer: GestureDetector(
            onTap: () {
              onBannerTap(photo);
            },
            child: GridTileBar(
              backgroundColor: Colors.black45,
              title: _GridTitleText(photo.title),
              subtitle: _GridTitleText(photo.caption),
              trailing: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
          child: image,
        );
    }
    assert(tileStyle != null);
    return null;
  }
}

class PageSlider extends StatefulWidget {
  final List<Photo> photos;
  final int selectedIndex;

  PageSlider(this.photos, this.selectedIndex);

  @override
  _PageSliderState createState() => _PageSliderState();
}

class _PageSliderState extends State<PageSlider> {
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.selectedIndex ?? 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        return Container(
            color: PlunesColors.BLACKCOLOR,
            child: Stack(
              children: <Widget>[
                PageView(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    children: widget.photos
                        .map((e) => GridPhotoViewer(photo: e))
                        .toList()),
                Positioned(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.close,
                        color: PlunesColors.WHITECOLOR,
                        size: 30,
                      ),
                    ),
                  ),
                  top: AppConfig.getMediaQuery().padding.top,
                  left: 5.0,
                ),
              ],
              fit: StackFit.expand,
            ));
      }),
    );
  }
}
