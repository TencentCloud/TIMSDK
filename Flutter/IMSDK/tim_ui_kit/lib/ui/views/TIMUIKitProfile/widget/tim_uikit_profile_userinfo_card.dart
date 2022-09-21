import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/utils/tui_theme.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class TIMUIKitProfileUserInfoCard extends TIMUIKitStatelessWidget {
  /// User info
  final V2TimUserFullInfo? userInfo;
  final bool isJumpToPersonalProfile;

  /// If shows the arrow icon on the right
  final bool showArrowRightIcon;

  TIMUIKitProfileUserInfoCard(
      {Key? key,
      this.userInfo,
      @Deprecated("This info card can no longer navigate to default personal profile page automatically, please deal with it manually.")
          this.isJumpToPersonalProfile = false,
      this.showArrowRightIcon = false})
      : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final TUITheme theme = value.theme;
    final faceUrl = userInfo?.faceUrl ?? "";
    final nickName = userInfo?.nickName ?? "";
    final signature = userInfo?.selfSignature;
    final showName = nickName != "" ? nickName : userInfo?.userID;
    final option1 = signature;
    final signatureText = option1 != null
        ? TIM_t_para("个性签名: {{option1}}", "个性签名: $option1")(option1: option1)
        : TIM_t("暂无个性签名");

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Avatar(
              faceUrl: faceUrl,
              showName: showName ?? "",
              type: 1,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text(
                    showName ?? "",
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    softWrap: true,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "ID:  ${userInfo?.userID ?? ""}",
                    style: TextStyle(fontSize: 13, color: theme.weakTextColor),
                  ),
                ),
                Text(signatureText,
                    style: TextStyle(fontSize: 13, color: theme.weakTextColor))
              ],
            ),
          ),
          showArrowRightIcon
              ? const Icon(Icons.keyboard_arrow_right)
              : Container()
        ],
      ),
    );
  }
}
