// ignore_for_file: prefer_typing_uninitialized_variables,  unused_import

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';

import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/constants/history_message_constant.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/permission.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_wrapper.dart';
import 'package:tim_ui_kit/ui/widgets/image_screen.dart';
import 'package:tim_ui_kit/ui/widgets/toast.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:tim_ui_kit/ui/utils/shared_theme.dart';

class TIMUIKitImageElem extends StatefulWidget {
  final V2TimMessage message;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final String? isFrom;
  final bool? isShowMessageReaction;

  const TIMUIKitImageElem(
      {required this.message,
      this.isShowJump = false,
      this.clearJump,
      this.isFrom,
      Key? key,
      this.isShowMessageReaction})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitImageElem();
}

class _TIMUIKitImageElem extends TIMUIKitState<TIMUIKitImageElem> {
  double? networkImagePositionRadio; // 加这个字段用于异步获取被安全打击后的兜底图的比例
  final TUIChatGlobalModel model = serviceLocator<TUIChatGlobalModel>();
  Widget? imageItem;
  bool isSent = false;

  @override
  didUpdateWidget(oldWidget) {
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
            LoadingAnimationWidget.staggeredDotsWave(
              color: theme?.weakTextColor ?? Colors.grey,
              size: 28,
            )
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
    var response;
    if (PlatformUtils().isWeb) {
      download(imageUrl) async {
        final http.Response r = await http.get(Uri.parse(imageUrl));
        final data = r.bodyBytes;
        final base64data = base64Encode(data);
        final a =
            html.AnchorElement(href: 'data:image/jpeg;base64,$base64data');
        a.download = md5.convert(utf8.encode(imageUrl)).toString();
        a.click();
        a.remove();
      }

      download(imageUrl);
      return;
    }
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
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("图片保存成功"),
            infoCode: 6660406));
      } else {
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("图片保存失败"),
            infoCode: 6660407));
      }
    } else {
      if (result != null) {
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("图片保存成功"),
            infoCode: 6660406));
      } else {
        onTIMCallback(TIMCallback(
            type: TIMCallbackType.INFO,
            infoRecommendText: TIM_t("图片保存失败"),
            infoCode: 6660407));
      }
    }
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
    if (path != null && PlatformUtils().isWeb
        ? true
        : File(path!).existsSync()) {
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

  Widget _renderLocalImage(
      String imgPath, dynamic heroTag, double positionRadio, TUITheme? theme) {
    double? currentPositionRadio;

    File imgF = File(imgPath);
    bool isExist = imgF.existsSync();

    if (!isExist) {
      return errorDisplay(context, theme);
    }
    Image image = Image.file(imgF);

    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) {
      if (image.image.width != 0 && image.image.height != 0) {
        currentPositionRadio = image.image.width / image.image.height;
      }
    }));
    final message = widget.message;
    final preloadImage = model.preloadImageMap[
        message.seq! + message.timestamp.toString() + (message.msgID ?? "")];

    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        AspectRatio(
          aspectRatio: currentPositionRadio ?? positionRadio,
          child: Container(
            decoration: const BoxDecoration(color: Colors.transparent),
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
                  child: preloadImage != null
                      ? RawImage(
                          image: preloadImage,
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        )
                      : Image.file(
                          File(imgPath),
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        ),
                )),
            imageElem: null)
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // 先暂时下掉用网络图片计算尺寸比例的feature，在没有找到准确的判断图片是否被打击前
    // setOnlineImageRatio();
  }

  void setOnlineImageRatio() {
    if (networkImagePositionRadio == null) {
      V2TimImage? smallImg = getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.small);
      V2TimImage? originalImg =
          getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.original);
      Image image = Image.network(smallImg?.url ?? originalImg?.url ?? "");

      image.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        if (info.image.width != 0 && info.image.height != 0) {
          setState(() {
            networkImagePositionRadio = (info.image.width / info.image.height);
          });
        }
      }));
    }
  }

  Widget _renderNetworkImage(
      dynamic heroTag, double positionRadio, TUITheme? theme,
      {String? path, V2TimImage? originalImg, V2TimImage? smallImg}) {
    try {
      String bigImgUrl = originalImg?.url ?? getBigPicUrl();
      if (bigImgUrl.isEmpty && smallImg?.url != null) {
        bigImgUrl = smallImg!.url!;
      }
      return Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          // AspectRatio(
          //   aspectRatio: networkImagePositionRadio ?? positionRadio,
          //   child: Container(
          //     decoration: const BoxDecoration(color: Colors.white),
          //   ),
          // ),
          getImage(
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                        opaque: false, // set to false
                        pageBuilder: (_, __, ___) => ImageScreen(
                            imageProvider: CachedNetworkImageProvider(
                              path ?? bigImgUrl,
                              cacheKey: widget.message.msgID,
                            ),
                            heroTag: heroTag,
                            messageID: widget.message.msgID,
                            downloadFn: () => _saveImg())),
                  );
                },
                child: Hero(
                    tag: heroTag,
                    child:
                        // Image.network(smallImg?.url ?? ""),
                        CachedNetworkImage(
                      // width: double.infinity,
                      alignment: Alignment.topCenter,
                      imageUrl: path ?? smallImg?.url ?? originalImg!.url!,
                      // use small image in message list as priority
                      errorWidget: (context, error, stackTrace) =>
                          errorPage(theme),
                      fit: BoxFit.contain,
                      cacheKey: smallImg?.uuid ?? originalImg!.uuid,
                      placeholder: (context, url) =>
                          Image(image: MemoryImage(kTransparentImage)),
                      fadeInDuration: const Duration(milliseconds: 0),
                    )),
              ),
              imageElem: e)
        ],
      );
    } catch (e) {
      return errorDisplay(context, theme);
    }
  }

  bool isNeedShowLocalPath() {
    final current = (DateTime.now().millisecondsSinceEpoch / 1000).ceil();
    final timeStamp = widget.message.timestamp ?? current;
    return (widget.message.isSelf ?? false) &&
        (isSent || current - timeStamp < 300);
  }

  Widget? _renderImage(dynamic heroTag, TUITheme? theme,
      {V2TimImage? originalImg, V2TimImage? smallImg}) {
    double positionRadio = 1.0;
    if (smallImg?.width != null &&
        smallImg?.height != null &&
        smallImg?.width != 0 &&
        smallImg?.height != 0) {
      positionRadio = (smallImg!.width! / smallImg.height!);
    }

    if (PlatformUtils().isWeb && widget.message.imageElem!.path != null) {
      // Displaying on Web only
      return _renderNetworkImage(heroTag, positionRadio, theme,
          smallImg: smallImg,
          originalImg: originalImg,
          path: widget.message.imageElem!.path);
    }

    try {
      if ((isNeedShowLocalPath() &&
          widget.message.imageElem!.path != null &&
          widget.message.imageElem!.path!.isNotEmpty &&
          File(widget.message.imageElem!.path!).existsSync())) {
        return _renderLocalImage(widget.message.imageElem!.path!, heroTag,
            networkImagePositionRadio ?? positionRadio, theme);
      }
    } catch (e) {
      print(e);
    }

    try {
      if (smallImg?.localUrl != null &&
          smallImg?.localUrl != "" &&
          File((smallImg?.localUrl!)!).existsSync()) {
        return _renderLocalImage(smallImg!.localUrl!, heroTag,
            networkImagePositionRadio ?? positionRadio, theme);
      }
    } catch (e) {
      print(e);
    }

    if ((smallImg?.url ?? originalImg?.url) != null &&
        (smallImg?.url ?? originalImg?.url)!.isNotEmpty) {
      return _renderNetworkImage(heroTag, positionRadio, theme,
          smallImg: smallImg, originalImg: originalImg);
    }

    return errorDisplay(context, theme);
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    if (widget.message.status == MessageStatus.V2TIM_MSG_STATUS_SENDING) {
      isSent = true;
    }
    final heroTag =
        "${widget.message.msgID ?? widget.message.id ?? widget.message.timestamp ?? DateTime.now().millisecondsSinceEpoch}${widget.isFrom}";

    V2TimImage? originalImg =
        getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.original);
    V2TimImage? smallImg = getImageFromList(V2_TIM_IMAGE_TYPES_ENUM.small);
    return TIMUIKitMessageReactionWrapper(
        isShowJump: widget.isShowJump,
        clearJump: widget.clearJump,
        isFromSelf: widget.message.isSelf ?? true,
        isShowMessageReaction: widget.isShowMessageReaction ?? true,
        message: widget.message,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * 0.5,
              minWidth: 64,
              maxHeight: 256,
            ),
            child: _renderImage(heroTag, theme,
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
