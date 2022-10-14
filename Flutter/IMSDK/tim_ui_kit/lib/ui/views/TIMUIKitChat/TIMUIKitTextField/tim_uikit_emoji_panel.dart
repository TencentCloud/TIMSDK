import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/constants/emoji.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/ui/utils/platform.dart';
import 'package:tim_ui_kit/ui/widgets/emoji.dart';

import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/ui/widgets/link_preview/common/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class EmojiPanel extends TIMUIKitStatelessWidget {
  final void Function(int unicode) onTapEmoji;
  final void Function() onSubmitted;
  final void Function() delete;
  final bool showBottomContainer;

  EmojiPanel({
    Key? key,
    required this.onTapEmoji,
    required this.onSubmitted,
    required this.delete,
    this.showBottomContainer = true, // 可选参数，是否展示下方的底部导航栏
  }) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    print(TIM_t(
        "暂未安装表情包插件，如需使用表情相关功能，请根据本文档安装：https://cloud.tencent.com/document/product/269/70746"));
    return SingleChildScrollView(
        child: Column(
      children: [
        Container(
          height: showBottomContainer ? 190 : 248,
          // color: theme.weakBackgroundColor,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(TIM_t("暂无表情包")),
            ],
          ),
        ),
        showBottomContainer
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: Container(
                        // color: Colors.white,
                        margin: const EdgeInsets.only(right: 25),
                        // height: MediaQuery.of(context).padding.bottom,
                        child: ElevatedButton(
                            child: Text(TIM_t("发送")),
                            style: ElevatedButton.styleFrom(),
                            onPressed: () {
                              onSubmitted();
                            })),
                  ),
                ],
              )
            : Container()
      ],
    ));
  }
}

class EmojiItem extends TIMUIKitStatelessWidget {
  EmojiItem({Key? key, required this.name, required this.unicode})
      : super(key: key);
  final String name;
  final int unicode;

  // final String toUser;
  // final int type;
  // final Function close;
  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: (PlatformUtils().isAndroid) ? 20 : 26,
      ),
      child: Text(
        String.fromCharCode(unicode),
      ),
    );
  }
}
