import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_image.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/route.dart';
import 'package:tim_ui_kit/ui/widgets/image_screen.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../../../../i18n/i18n_utils.dart';
import '../../../../tim_ui_kit.dart';

class TIMUIKitImageElem extends StatefulWidget {
  final V2TimMessage message;
  const TIMUIKitImageElem({required this.message, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitImageElem();
}

class _TIMUIKitImageElem extends State<TIMUIKitImageElem> {
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

  getBigPicUrl() {
    // 实际拿的是原图
    V2TimImage? img = MessageUtils.getImageFromImgList(
        widget.message.imageElem!.imageList,
        HistoryMessageDartConstant.oriImgPrior);
    return img == null ? widget.message.imageElem!.path! : img.url!;
  }

  Widget errorDisplay(BuildContext context, TUITheme? theme) {
    final I18nUtils ttBuild = I18nUtils(context);
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
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: theme?.cautionColor,
              size: 16,
            ),
            Text(
              ttBuild.imt("图片加载失败"),
              style: TextStyle(color: theme?.cautionColor),
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
    final I18nUtils ttBuild = I18nUtils(context);
    var response;
    if (Platform.isIOS) {
      if (!await Permissions.checkPermission(
          context, Permission.photosAddOnly.value)) {
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
        Toast.showToast(ToastType.success, ttBuild.imt("图片保存成功"), context);
      } else {
        Toast.showToast(ToastType.success, ttBuild.imt("图片保存失败"), context);
      }
    } else {
      if (result != null) {
        Toast.showToast(ToastType.success, ttBuild.imt("图片保存成功"), context);
      } else {
        Toast.showToast(ToastType.success, ttBuild.imt("图片保存失败"), context);
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

  void _saveImg({String? elemPath, String? originalUrl}) {
    String? path = elemPath ?? widget.message.imageElem?.path;
    String? imageUrl = originalUrl ??
        (path == "" ? widget.message.imageElem?.imageList![0]?.url : path);
    bool isAsset = (path != "" && File(path!).existsSync());
    if (imageUrl != null) {
      _savenNetworkImage(context, imageUrl, isAsset: isAsset);
    }
  }

  void openDialog(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) {
          final I18nUtils ttBuild = I18nUtils(context);
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PhotoView(
                    tightMode: true,
                    imageProvider: NetworkImage(
                      getBigPicUrl(),
                    ),
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.message.msgID!),
                  ),
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.file_download),
                      label: Text(ttBuild.imt("保存")),
                      onPressed: () {
                        String? path = widget.message.imageElem?.path;
                        String? imageUrl = path == ""
                            // 第0项一般为原图
                            ? widget.message.imageElem?.imageList![0]?.url
                            : path;
                        bool isAsset = (path != "" && File(path!).existsSync());
                        if (imageUrl != null) {
                          _savenNetworkImage(context, imageUrl,
                              isAsset: isAsset);
                        }
                      },
                    ),
                  )
                ],
              ));
        },
      );

  V2TimImage? getImageFromList(V2_TIM_IMAGE_TYPES_ENUM imgType) {
    V2TimImage? img = MessageUtils.getImageFromImgList(
        widget.message.imageElem!.imageList,
        HistoryMessageDartConstant.imgPriorMap[imgType] ??
            HistoryMessageDartConstant.oriImgPrior);
    if (img == null) {
      setState(() {
        imageIsRender = true;
      });
    }
    return img;
  }

  Widget imageBuilder(BoxConstraints constraints, TUITheme? theme,
      {V2TimImage? originalImg, V2TimImage? smallImg}) {
    if (originalImg == null) {
      // 有path
      if (widget.message.imageElem!.path!.isNotEmpty) {
        return getImage(
            Image.file(File(widget.message.imageElem!.path!),
                fit: BoxFit.fitWidth),
            imageElem: null);
      } else {
        return errorDisplay(context, theme);
      }
    } else if (widget.message.imageElem!.path!.isNotEmpty &&
        File(widget.message.imageElem!.path!).existsSync() &&
        !imageIsRender) {
      // if local resources image is available, use it as priority
      return getImage(
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(FadeRoute(
                  page: ImageScreen(
                      imageProvider:
                          AssetImage(widget.message.imageElem!.path!),
                      heroTag: widget.message.msgID!,
                      downloadFn: () =>
                          _saveImg(elemPath: widget.message.imageElem!.path))));
            },
            child: Image.file(File(widget.message.imageElem!.path!),
                fit: BoxFit.fitWidth),
          ),
          imageElem: e);
    } else if ((smallImg?.url ?? originalImg.url) != null && !imageIsRender) {
      return getImage(
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(FadeRoute(
                page: CachedNetworkImage(
                  imageUrl: originalImg.url ?? getBigPicUrl(),
                  imageBuilder: (context, imageProvider) => ImageScreen(
                      imageProvider: imageProvider,
                      heroTag: widget.message.msgID!,
                      downloadFn: () =>
                          _saveImg(elemPath: widget.message.imageElem!.path)),
                  placeholder: (context, url) => Container(
                    color: Colors.black,
                  ),
                  errorWidget: (context, url, error) => errorDisplay(context, theme),
                  fadeInDuration: const Duration(milliseconds: 0),
                ),
              ));
            },
            child: CachedNetworkImage(
              imageUrl: smallImg?.url ??
                  originalImg
                      .url!, // use small image in message list as priority
              errorWidget: (context, error, stackTrace) => errorDisplay(context, theme),
              fit: BoxFit.fitWidth,
              cacheKey: smallImg?.uuid ?? originalImg.uuid!,
              placeholder: (context, url) =>
                  Image(image: MemoryImage(kTransparentImage)),
              fadeInDuration: const Duration(milliseconds: 0),
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
                        imageProvider: NetworkImage(getBigPicUrl()),
                        heroTag: widget.message.msgID!,
                        downloadFn: () => _saveImg(
                            elemPath: widget.message.imageElem!.path))));
              },
              child: Image.file(File(widget.message.imageElem!.path!),
                  fit: BoxFit.fitWidth),
            ),
            imageElem: null);
      } else {
        return errorDisplay(context, theme);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;
    V2TimImage? originalImg =
        getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.original);
    V2TimImage? smallImg = getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.small);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: constraints.maxWidth * 0.4, minWidth: 0),
          child: imageBuilder(constraints, theme,
              originalImg: originalImg, smallImg: smallImg));
    });
  }
}
