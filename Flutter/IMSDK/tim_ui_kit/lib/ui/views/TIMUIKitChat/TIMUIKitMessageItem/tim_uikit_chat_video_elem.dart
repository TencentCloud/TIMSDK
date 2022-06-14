import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/message_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_theme_view_model.dart';
import 'package:tim_ui_kit/i18n/i18n_utils.dart';

import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/video_screen.dart';
import 'package:transparent_image/transparent_image.dart';

class TIMUIKitVideoElem extends StatefulWidget {
  final V2TimMessage message;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final String? isFrom;

  const TIMUIKitVideoElem(this.message,
      {Key? key, this.isShowJump = false, this.clearJump, this.isFrom})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitVideoElemState();
}

class _TIMUIKitVideoElemState extends State<TIMUIKitVideoElem> {
  bool isShowBorder = false;

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

  Widget errorDisplay(TUITheme? theme) {
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
              ttBuild.imt("视频加载失败"),
              style: TextStyle(color: theme?.cautionColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final theme = SharedThemeWidget.of(context)?.theme;
    final theme = Provider.of<TUIThemeViewModel>(context).theme;
    // Random 为了解决reply时的Hero同层Tag相同问题
    final heroTag =
        "${widget.message.msgID ?? widget.message.id ?? widget.message.timestamp ?? DateTime.now().millisecondsSinceEpoch}${widget.isFrom}";
    if (widget.isShowJump) {
      _showJumpColor();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false, // set to false
            pageBuilder: (_, __, ___) => VideoScreen(
              message: widget.message,
              heroTag: heroTag,
            ),
          ),
        );
      },
      child: Hero(
          tag: heroTag,
          child: Container(
            // constraints: BoxConstraints(
            //     maxWidth: adaptWidth["width"], maxHeight: adaptWidth["height"]),
            decoration: BoxDecoration(
              border: Border.all(
                color: isShowBorder
                    ? const Color.fromRGBO(245, 166, 35, 1)
                    : (theme.weakDividerColor ?? CommonColor.weakDividerColor),
                width: 1,
                style: BorderStyle.solid,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                double positionRadio = 1.0;
                if (widget.message.videoElem?.snapshotWidth != null &&
                    widget.message.videoElem?.snapshotHeight != null &&
                    widget.message.videoElem?.snapshotWidth != 0 &&
                    widget.message.videoElem?.snapshotHeight != 0) {
                  positionRadio = (widget.message.videoElem!.snapshotWidth! /
                      widget.message.videoElem!.snapshotHeight!);
                }

                return ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.5, minWidth: 0),
                    child: Stack(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: positionRadio,
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Colors.white),
                          ),
                        ),
                        Positioned(
                            // 当消息处于发送状态时，请使用本地资源
                            child: widget.message.videoElem!.snapshotUrl ==
                                        null ||
                                    widget.message.status ==
                                        MessageStatus.V2TIM_MSG_STATUS_SENDING
                                ? ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight: 420.h, //宽度尽可能大
                                        maxWidth: 320.w //最小高度为50像素
                                        ),
                                    child: Image.file(
                                        File(widget
                                            .message.videoElem!.snapshotPath!),
                                        fit: BoxFit.fitWidth),
                                  )
                                : (widget.message.videoElem?.localSnapshotUrl ==
                                            null ||
                                        widget.message.videoElem
                                                ?.localSnapshotUrl ==
                                            "")
                                    ? CachedNetworkImage(
                                        placeholder: (context, url) => Image(
                                            image:
                                                MemoryImage(kTransparentImage)),
                                        cacheKey:
                                            widget.message.videoElem!.UUID,
                                        fit: BoxFit.fitWidth,
                                        imageUrl: widget
                                            .message.videoElem!.snapshotUrl!,
                                        errorWidget: (context, url, error) =>
                                            errorDisplay(theme),
                                      )
                                    : Image.file(
                                        File(widget.message.videoElem!
                                            .localSnapshotUrl!),
                                        fit: BoxFit.fitWidth)),
                        Positioned.fill(
                          // alignment: Alignment.center,
                          child: Center(
                              child: Image.asset('images/play.png',
                                  package: 'tim_ui_kit', height: 64)),
                        ),
                        Positioned(
                            right: 10,
                            bottom: 10,
                            child: Text(
                                MessageUtils.formatVideoTime(
                                        widget.message.videoElem?.duration ?? 0)
                                    .toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12))),
                      ],
                    ));
              }),
            ),
          )),
    );
  }
}
