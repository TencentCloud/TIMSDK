import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:discuss/utils/commonUtils.dart';
import 'package:discuss/utils/const.dart';
import 'package:discuss/utils/permissions.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_image.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:photo_view/photo_view.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'ImageScreen.dart';

class ImageMessage extends StatefulWidget {
  final V2TimMessage message;
  final bool isSelect;
  const ImageMessage({required this.message, required this.isSelect, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageMessageState();
}

class ImageMessageState extends State<ImageMessage> {
  bool imageIsRender = false;

  /*
  为了解决，重复渲染的跳闪问题
  当现有图片队列只有一个，且上一个图片队列不存在时才进行更新，因为此时是发送了新的图片
  */

  @override
  didUpdateWidget(oldWidget) {
    var oldImgListLength = oldWidget.message.imageElem?.imageList?.length ?? 0;
    var currImgListLength = widget.message.imageElem?.imageList?.length ?? 0;
    if (currImgListLength == 1 && oldImgListLength == 0) {
      setState(() {
        imageIsRender = true;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  getBigPic() {
    V2TimImage? img;
    img = widget.message.imageElem!.imageList!.firstWhere(
        (e) => e?.type == Const.V2_TIM_IMAGE_TYPES['SMALL'],
        orElse: () => null);
    img = widget.message.imageElem!.imageList!.firstWhere(
        (e) => e?.type == Const.V2_TIM_IMAGE_TYPES['BIG'],
        orElse: () => null);
    img = widget.message.imageElem!.imageList!.firstWhere(
        (e) => e?.type == Const.V2_TIM_IMAGE_TYPES['ORIGINAL'],
        orElse: () => null);
    return img == null ? widget.message.imageElem!.path! : img.url!;
  }

  Widget errorDisplay() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        width: 1,
        color: Colors.black12,
      )),
      height: 100,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.warning_amber_outlined,
              color: Colors.red,
              size: 16,
            ),
            Text(
              "图片加载失败",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget getImage(image, {imageElem}) {
    Widget res = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: image,
    );

    return res;
  }

  //保存网络图片到本地
  _savenNetworkImage(context, String imageUrl, {bool isAsset = true}) async {
    Uint8List response;
    if (Platform.isIOS) {
      if (!await Permissions.checkPermission(
          context, Permission.photos.value)) {
        return;
      }
    } else {
      if (!await Permissions.checkPermission(
          context, Permission.storage.value)) {
        return;
      }
    }

    // 本地资源的情况下
    if (isAsset) {
      File file = File(imageUrl);
      response = await file.readAsBytes();
    } else {
      var res = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));
      response = res.data;
    }

    var result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response));

    if (Platform.isIOS) {
      if (result['isSuccess']) {
        Fluttertoast.showToast(msg: '保存成功', gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: '保存失败', gravity: ToastGravity.CENTER);
      }
    } else {
      if (result != null) {
        Fluttertoast.showToast(msg: '保存成功', gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: '保存失败', gravity: ToastGravity.CENTER);
      }
    }
  }

  getImgWidthAndHeight(
      BoxConstraints constraints, double height, double width) {
    // 消息列表展示缩略图的大小
    double hwrate = height / width;
    double curWidth = min(width, constraints.maxWidth * 0.4);
    double curHeight = curWidth * hwrate;
    return {height: curHeight, width: curWidth};
  }

  void _saveImg() {
    String? path = widget.message.imageElem?.path;
    String? imageUrl = path == ""
        // 第0项一般为原图
        ? widget.message.imageElem?.imageList![0]?.url
        : path;
    bool isAsset = path != "" ? true : false;
    if (imageUrl == null) {
      return;
    }
    _savenNetworkImage(context, imageUrl, isAsset: isAsset);
  }

  void openDialog(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PhotoView(
                    tightMode: true,
                    imageProvider: NetworkImage(
                      getBigPic(),
                    ),
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.message.msgID!),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.file_download),
                      label: const Text("保存"),
                      onPressed: () {
                        String? path = widget.message.imageElem?.path;
                        String? imageUrl = path == ""
                            // 第0项一般为原图
                            ? widget.message.imageElem?.imageList![0]?.url
                            : path;
                        bool isAsset = path != "" ? true : false;
                        if (imageUrl == null) {
                          return;
                        }
                        _savenNetworkImage(context, imageUrl, isAsset: isAsset);
                      },
                    ),
                  )
                ],
              ));
        },
      );

  V2TimImage? getImageFromList() {
    V2TimImage? img;
    // 缩略图优先，大图次之，最后是原图
    img = widget.message.imageElem!.imageList?.firstWhere(
        (e) => e!.type == Const.V2_TIM_IMAGE_TYPES['ORIGINAL'],
        orElse: () => null);
    img = widget.message.imageElem!.imageList?.firstWhere(
        (e) => e!.type == Const.V2_TIM_IMAGE_TYPES['BIG'],
        orElse: () => null);
    img = widget.message.imageElem!.imageList?.firstWhere(
        (e) => e!.type == Const.V2_TIM_IMAGE_TYPES['SMALL'],
        orElse: () => null);
    if (img == null) {
      setState(() {
        imageIsRender = true;
      });
    }
    return img;
  }

  Widget imageBuilder(BoxConstraints constraints, V2TimImage? img) {
    if (img == null) {
      // 有path
      if (widget.message.imageElem!.path!.isNotEmpty) {
        return getImage(
            Image.file(File(widget.message.imageElem!.path!),
                fit: BoxFit.fitWidth),
            imageElem: null);
      } else {
        return errorDisplay();
      }
    } else if (img.url != null && !imageIsRender) {
      return getImage(
          GestureDetector(
            onTap: () {
              // openDialog(context);
              Navigator.of(context).push(FadeRoute(
                  page: ImageScreen(
                      imageProvider: NetworkImage(getBigPic()),
                      heroTag: widget.message.msgID!,
                      downloadFn: _saveImg)));
            },
            child:
                // Container(
                // height: height + 10,
                // decoration: BoxDecoration(
                //   borderRadius:
                //       const BorderRadius.all(Radius.circular(20)),
                //   border: Border.all(
                //     color: hexToColor("E5E5E5"),
                //     width: 1,
                //     style: BorderStyle.solid,
                //   ),
                // ),
                FadeInImage.memoryNetwork(
              fadeInCurve: Curves.ease,
              fit: BoxFit.fitWidth,
              image: img.url!,
              placeholder: kTransparentImage,
              imageErrorBuilder: (context, error, stackTrace) => errorDisplay(),
            ),
          ),
          imageElem: e);
    } else {
      // 有path
      if (widget.message.imageElem!.path!.isNotEmpty) {
        return getImage(
            GestureDetector(
              onTap: () {
                // openDialog(context);
                Navigator.of(context).push(FadeRoute(
                    page: ImageScreen(
                        imageProvider: NetworkImage(getBigPic()),
                        heroTag: widget.message.msgID!,
                        downloadFn: _saveImg)));
              },
              child: Image.file(File(widget.message.imageElem!.path!),
                  fit: BoxFit.fitWidth),
            ),
            imageElem: null);
      } else {
        return errorDisplay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    V2TimImage? img = getImageFromList();
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Align(
        alignment: widget.message.isSelf!
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.4),
            child: imageBuilder(constraints, img)),
      );
    });
  }
}
