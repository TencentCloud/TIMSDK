import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen(
      {required this.imageProvider,
      required this.heroTag,
      required this.downloadFn,
      Key? key})
      : super(key: key);

  final ImageProvider imageProvider;
  final String heroTag;
  final void Function() downloadFn;

  @override
  State<StatefulWidget> createState() {
    return _ImageScreenState();
  }
}

class _ImageScreenState extends State<ImageScreen> {
  bool _hideStuff = true;

  _onTap() {
    setState(() {
      _hideStuff = !_hideStuff;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: GestureDetector(
          onTap: _onTap,
          // onPanStart: (DragStartDetails details) {
          //   Utils.log('start $details');
          // },
          // onPanUpdate: (DragUpdateDetails details) {
          //   Utils.log('update $details');
          // },
          // onPanEnd: (DragEndDetails details) {
          //   Utils.log('end $details');
          // },
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0,
                child: PhotoView(
                  imageProvider: widget.imageProvider,
                  loadingBuilder:
                      (BuildContext context, ImageChunkEvent? event) {
                    return Container(color: Colors.black);
                  },
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 1.8,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.heroTag),
                  enableRotation: false,
                ),
              ),
              Positioned(
                left: 10,
                bottom: 50,
                child: AnimatedOpacity(
                    opacity: _hideStuff ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Image.asset(
                        'images/close.png',
                        package: 'tim_ui_kit',
                      ),
                      iconSize: 30,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
              ),
              Positioned(
                right: 10,
                bottom: 50,
                child: AnimatedOpacity(
                    opacity: _hideStuff ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Image.asset(
                        'images/download.png',
                        package: 'tim_ui_kit',
                      ),
                      iconSize: 30,
                      onPressed: widget.downloadFn,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
