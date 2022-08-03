import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_class.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';

class TIMUIKitProfileWidget extends TIMUIKitClass {
  static Widget operationDivider() {
    return const SizedBox(
      height: 10,
    );
  }

  /// Remarks
  static Widget remarkBar(String remark, Function()? handleTap) {
    return InkWell(
      onTap: () {
        if (handleTap != null) {
          handleTap();
        }
      },
      child: TIMUIKitOperationItem(
        operationName: TIM_t("备注名"),
        operationRightWidget: Text(remark),
      ),
    );
  }

  /// add to block list
  static Widget addToBlackListBar(
      bool value, BuildContext context, Function(bool value)? onChanged) {
    return TIMUIKitOperationItem(
      operationName: TIM_t("加入黑名单"),
      type: "switch",
      operationValue: value,
      onSwitchChange: (value) {
        if (onChanged != null) {
          onChanged(value);
        }
      },
    );
  }

  /// pin the conversation to the top
  static Widget pinConversationBar(
      bool value, BuildContext context, Function(bool value)? onChanged) {
    return TIMUIKitOperationItem(
      operationName: TIM_t("置顶聊天"),
      type: "switch",
      operationValue: value,
      onSwitchChange: (value) {
        if (onChanged != null) {
          onChanged(value);
        }
      },
    );
  }

  /// message disturb
  static Widget messageDisturb(
      BuildContext context, bool isDisturb, Function(bool value)? onChanged) {
    return TIMUIKitOperationItem(
      operationName: TIM_t("消息免打扰"),
      type: "switch",
      operationValue: isDisturb,
      onSwitchChange: (value) {
        if (onChanged != null) {
          onChanged(value);
        }
      },
    );
  }

  static Widget operationItem({
    required String operationName,
    required String type,
    bool? operationValue,
    String? operationText,
    void Function(bool newValue)? onSwitchChange,
  }) {
    return TIMUIKitOperationItem(
      operationName: operationName,
      type: type,
      operationRightWidget: Text(operationText ?? ""),
      operationValue: operationValue,
      onSwitchChange: onSwitchChange,
    );
  }

  /// find history message
  static Widget searchBar(BuildContext context, V2TimConversation conversation,
      {Function()? handleTap}) {
    return InkWell(
      onTap: () {
        if (handleTap != null) {
          handleTap();
        }
      },
      child: TIMUIKitOperationItem(
        operationName: TIM_t("查找聊天内容"),
      ),
    );
  }

  /// portrait
  static Widget portraitBar(Widget portraitWidget) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        operationName: TIM_t("头像"),
        operationRightWidget: portraitWidget,
        showArrowRightIcon: false,
      ),
    );
  }

  /// defaultPortraitWidget
  static Widget defaultPortraitWidget(V2TimUserFullInfo? userInfo) {
    return SizedBox(
      width: 48,
      height: 48,
      child: userInfo != null ? Avatar(
          faceUrl: userInfo.faceUrl ?? "", showName: userInfo.nickName ?? "",type: 1,) : Container(),
    );
  }

  /// nickname
  static Widget nicknameBar(String nickName) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        showArrowRightIcon: false,
        operationName: TIM_t("昵称"),
        operationRightWidget: Text(nickName),
      ),
    );
  }

  /// user account
  static Widget userAccountBar(String userNum) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        showArrowRightIcon: false,
        operationName: TIM_t("账号"),
        operationRightWidget: Text(userNum),
      ),
    );
  }

  /// signature
  static Widget signatureBar(String signature) {
    return SizedBox(
      child: TIMUIKitOperationItem(
        showArrowRightIcon: false,
        operationName: TIM_t("个性签名"),
        operationRightWidget: Text(signature),
      ),
    );
  }

  /// gender
  static Widget genderBar(int gender) {
    Map genderMap = {
      0: TIM_t("未知"),
      1: TIM_t("男"),
      2: TIM_t("女"),
    };
    return SizedBox(
      child: TIMUIKitOperationItem(
        showArrowRightIcon: false,
        operationName: TIM_t("性别"),
        operationRightWidget: Text(genderMap[gender]),
      ),
    );
  }

  /// gender
  static Widget genderBarWithArrow(int gender) {
    Map genderMap = {
      0: TIM_t("未知"),
      1: TIM_t("男"),
      2: TIM_t("女"),
    };
    return SizedBox(
      child: TIMUIKitOperationItem(
        operationName: TIM_t("性别"),
        operationRightWidget: Text(genderMap[gender]),
      ),
    );
  }

  /// birthday
  static Widget birthdayBar(int? birthday) {
    if (birthday == 0 || birthday == null) {
      return InkWell(
        onTap: () {},
        child: TIMUIKitOperationItem(
          showArrowRightIcon: false,
          operationName: TIM_t("生日"),
          operationRightWidget: Text(TIM_t("未知")),
        ),
      );
    }
    final date = DateTime.parse(birthday.toString());
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    return InkWell(
      onTap: () {},
      child: TIMUIKitOperationItem(
        showArrowRightIcon: false,
        operationName: TIM_t("生日"),
        operationRightWidget: Text(formatter.format(date)),
      ),
    );
  }

  /// default button area
  static Widget addAndDeleteArea(

    V2TimFriendInfo friendInfo,
    V2TimConversation conversation,
    int friendType,
    bool isDisturb,
    bool isBlocked,
    TUITheme theme,
    VoidCallback handleAddFriend,
    VoidCallback handleDeleteFriend,
  ) {
    _buildDeleteFriend(V2TimConversation conversation, theme) {
      return InkWell(
        onTap: () {
          handleDeleteFriend();
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(bottom: BorderSide(color: theme.weakDividerColor))),
          child: Text(
            TIM_t("清除好友"),
            style: TextStyle(color: theme.cautionColor, fontSize: 17),
          ),
        ),
      );
    }

    _buildAddOperation() {
      return Container(
        alignment: Alignment.center,
        // padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                bottom: BorderSide(
                    color: theme.weakDividerColor ??
                        CommonColor.weakDividerColor))),
        child: Row(children: [
          Expanded(
            child: TextButton(
                child: Text(TIM_t("加为好友"),
                    style: TextStyle(color: theme.primaryColor, fontSize: 17)),
                onPressed: () {
                  handleAddFriend();
                }),
          )
        ]),
      );
    }

    return Column(
      children: [
        if (friendType != 0) _buildDeleteFriend(conversation, theme),
        if (friendType == 0 && !isBlocked) _buildAddOperation()
      ],
    );
  }
}
