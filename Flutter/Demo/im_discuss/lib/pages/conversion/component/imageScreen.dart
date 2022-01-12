import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
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
                  imageProvider: imageProvider,
                  // TODO loading
                  // loadingBuilder: (BuildContext context, ImageChunkEvent? event) {
                  //   return Container();
                  // },
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 1.8,
                  heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
                  enableRotation: false,
                ),
              ),
              // Positioned(
              //   left: 10,
              //   bottom: 50,
              //   child: IconButton(
              //     icon: Image.asset('images/close.png'),
              //     iconSize: 30,
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //   ),
              // ),
              Positioned(
                right: 10,
                bottom: 50,
                child: IconButton(
                  icon: Image.asset('images/download.png'),
                  iconSize: 30,
                  onPressed: downloadFn,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
