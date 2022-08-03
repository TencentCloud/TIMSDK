import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

import 'package:tim_ui_kit/ui/utils/message.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitMessageItem/TIMUIKitMessageReaction/tim_uikit_message_reaction_wrapper.dart';
import 'package:tim_ui_kit/ui/widgets/video_screen.dart';
import 'package:transparent_image/transparent_image.dart';

class TIMUIKitVideoElem extends StatefulWidget {
  final V2TimMessage message;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final String? isFrom;
  final bool? isShowMessageReaction;

  const TIMUIKitVideoElem(this.message,
      {Key? key,
      this.isShowJump = false,
      this.clearJump,
      this.isFrom,
      this.isShowMessageReaction})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitVideoElemState();
}

class _TIMUIKitVideoElemState extends TIMUIKitState<TIMUIKitVideoElem> {
  Widget errorDisplay(TUITheme? theme) {
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
              TIM_t("视频加载失败"),
              style: TextStyle(color: theme?.cautionColor),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final heroTag =
        "${widget.message.msgID ?? widget.message.id ?? widget.message.timestamp ?? DateTime.now().millisecondsSinceEpoch}${widget.isFrom}";

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
          child: TIMUIKitMessageReactionWrapper(message: widget.message,
          isShowJump: widget.isShowJump,
          isShowMessageReaction: widget.isShowMessageReaction ?? true,
          clearJump: widget.clearJump,
          isFromSelf: widget.message.isSelf ?? true,
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
          ),)),
    );
  }
}
