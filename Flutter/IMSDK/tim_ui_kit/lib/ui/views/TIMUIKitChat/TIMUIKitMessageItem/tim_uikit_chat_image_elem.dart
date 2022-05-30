// ignore_for_file: prefer_typing_uninitialized_variables, unnecessary_import

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_image.dart';

import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/widgets/image_screen.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:tim_ui_kit/ui/utils/shared_theme.dart';

class TIMUIKitImageElem extends StatefulWidget {
  final V2TimMessage message;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final String? isFrom;

  const TIMUIKitImageElem(
      {required this.message,
      this.isShowJump = false,
      this.clearJump,
      this.isFrom,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitImageElem();
}

class _TIMUIKitImageElem extends State<TIMUIKitImageElem> {
  bool imageIsRender = false;
  bool isShowBorder = false;
  final TUIChatViewModel model = serviceLocator<TUIChatViewModel>();

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

  String getBigPicUrl() {
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
          borderRadius: const BorderRadius.all(Radius.circular(5)),
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
      clipper: ImageClipper(),
      child: image,
    );

    return res;
  }

  //保存网络图片到本地
  _saveImageToLocal(context, String imageUrl, {bool isAsset = true}) async {
    final I18nUtils ttBuild = I18nUtils(context);
    var response;
    if (PlatformUtils().isIOS) {
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
          .get(imageUrl, options: Options(responseType: ResponseType.bytes),
              onReceiveProgress: (recv, total) {
        if (total != -1) {
          model.setMessageProgress(
              widget.message.msgID!, (recv / total * 100).ceil());
        }
      });
      response = res.data;
    }
    model.setMessageProgress(widget.message.msgID!, 0);
    var result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response));

    if (PlatformUtils().isIOS) {
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

  void _showJumpColor() {
    int shineAmount = 10;
    setState(() {
      isShowBorder = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      widget.clearJump!();
    });
    Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (mounted) {
        setState(() {
          isShowBorder = shineAmount.isOdd ? true : false;
        });
      }
      if (shineAmount == 0 || !mounted) {
        timer.cancel();
      }
      shineAmount--;
    });
  }

  getImgWidthAndHeight(
      BoxConstraints constraints, double height, double width) {
    // 消息列表展示缩略图的大小
    double hwrate = height / width;
    double curWidth = min(width, constraints.maxWidth * 0.5);
    double curHeight = curWidth * hwrate;
    return {height: curHeight, width: curWidth};
  }

  void _saveImg() {
    String? path = widget.message.imageElem!.path;
    if (path != null && File(path).existsSync()) {
      _saveImageToLocal(context, path, isAsset: true);
    } else {
      String imgUrl = getBigPicUrl();
      _saveImageToLocal(context, imgUrl, isAsset: false);
    }
  }

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

  Widget errorPage(theme) => Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: errorDisplay(context, theme),
      ));

  Widget _renderLocalImage(String imgPath, dynamic heroTag,
      [V2TimImage? originalImg]) {
    double positionRadio = 1.0;
    if (originalImg?.width != null &&
        originalImg?.height != null &&
        originalImg?.width != 0 &&
        originalImg?.height != 0) {
      positionRadio = (originalImg!.width! / originalImg.height!);
    }
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        AspectRatio(
          aspectRatio: positionRadio,
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
          ),
        ),
        getImage(
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false, // set to false
                      pageBuilder: (_, __, ___) => ImageScreen(
                          imageProvider: FileImage(File(imgPath)),
                          heroTag: heroTag,
                          messageID: widget.message.msgID,
                          downloadFn: () => _saveImg()),
                    ),
                  );
                },
                child: Hero(
                  tag: heroTag,
                  child: Image.file(
                    File(imgPath),
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                  ),
                )),
            imageElem: null)
      ],
    );
  }

  Widget imageBuilder(dynamic heroTag, TUITheme? theme,
      {V2TimImage? originalImg, V2TimImage? smallImg}) {
    if (originalImg?.localUrl != null && originalImg?.localUrl != "") {
      return _renderLocalImage(originalImg!.localUrl!, heroTag, smallImg);
    } else if (widget.message.imageElem!.path!.isNotEmpty &&
        File(widget.message.imageElem!.path!).existsSync()) {
      return _renderLocalImage(
          widget.message.imageElem!.path!, heroTag, smallImg);
    } else if ((smallImg?.url ?? originalImg?.url) != null) {
      double positionRadio = 1.0;
      if (smallImg?.width != null &&
          smallImg?.height != null &&
          smallImg?.width != 0 &&
          smallImg?.height != 0) {
        positionRadio = (smallImg!.width! / smallImg.height!);
      }
      String bigImgUrl = originalImg?.url ?? getBigPicUrl();
      if (bigImgUrl.isEmpty && smallImg?.url != null) {
        bigImgUrl = smallImg!.url!;
      }
      return Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          AspectRatio(
            aspectRatio: positionRadio,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
            ),
          ),
          getImage(
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                        opaque: false, // set to false
                        pageBuilder: (_, __, ___) => ImageScreen(
                            imageProvider: CachedNetworkImageProvider(
                              bigImgUrl,
                              cacheKey: widget.message.msgID,
                            ),
                            heroTag: heroTag,
                            messageID: widget.message.msgID,
                            downloadFn: () => _saveImg())),
                  );
                },
                child: Hero(
                    tag: heroTag,
                    child: CachedNetworkImage(
                      width: double.infinity,
                      alignment: Alignment.topCenter,
                      imageUrl: smallImg?.url ?? originalImg!.url!,
                      // use small image in message list as priority
                      errorWidget: (context, error, stackTrace) =>
                          errorPage(theme),
                      fit: BoxFit.fitWidth,
                      cacheKey: smallImg?.uuid ?? originalImg!.uuid,
                      placeholder: (context, url) =>
                          Image(image: MemoryImage(kTransparentImage)),
                      fadeInDuration: const Duration(milliseconds: 0),
                    )),
              ),
              imageElem: e)
        ],
      );
    } else {
      return errorDisplay(context, theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SharedThemeWidget.of(context)?.theme;
    // Random 为了解决reply时的Hero同层Tag相同问题
    final heroTag =
        "${widget.message.msgID ?? widget.message.id ?? widget.message.timestamp ?? DateTime.now().millisecondsSinceEpoch}${widget.isFrom}";

    V2TimImage? originalImg =
        getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.original);
    V2TimImage? smallImg = getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.small);
    if (widget.isShowJump) {
      _showJumpColor();
    }
    return Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(
                color: Color.fromRGBO(245, 166, 35, (isShowBorder ? 1 : 0)),
                width: 2)),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.5,
              minWidth: 64,
              maxHeight: 256,
            ),
            child: imageBuilder(heroTag, theme,
                originalImg: originalImg, smallImg: smallImg),
          );
        }));
  }
}

class ImageClipper extends CustomClipper<RRect> {
  @override
  RRect getClip(Size size) {
    return RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, min(size.height, 256)),
        const Radius.circular(5));
  }

  @override
  bool shouldReclip(CustomClipper<RRect> oldClipper) {
    return oldClipper != this;
  }
}
