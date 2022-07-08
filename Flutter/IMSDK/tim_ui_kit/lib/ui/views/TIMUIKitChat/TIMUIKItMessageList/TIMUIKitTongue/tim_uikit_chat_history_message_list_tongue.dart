import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_statelesswidget.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_tongue_item.dart';
import 'package:tim_ui_kit/base_widgets/tim_ui_kit_base.dart';

enum MessageListTongueType {
  none,
  toLatest,
  showUnread,
  atMe,
  atAll,
}

typedef TongueItemBuilder = Widget Function(
    VoidCallback onClick, MessageListTongueType valueType, int unreadCount);

class TIMUIKitHistoryMessageListTongue extends TIMUIKitStatelessWidget {
  /// the value type currently
  final MessageListTongueType valueType;

  /// the callback after clicking
  final VoidCallback onClick;

  /// unread amount currently
  final int unreadCount;

  /// the builder for tongue item
  final TongueItemBuilder? tongueItemBuilder;

  /// total amount of messages at me
  final String atNum;

  TIMUIKitHistoryMessageListTongue({
    Key? key,
    required this.valueType,
    required this.onClick,
    required this.unreadCount,
    this.tongueItemBuilder,
    this.atNum = "",
  }) : super(key: key);

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    late Widget tongueItem;
    if (tongueItemBuilder != null) {
      tongueItem = tongueItemBuilder!(onClick, valueType, unreadCount);
    } else {
      tongueItem = TIMUIKitTongueItem(
        onClick: onClick,
        unreadCount: unreadCount,
        valueType: valueType,
        atNum: atNum,
      );
    }
    return valueType != MessageListTongueType.none ? tongueItem : Container();
  }
}
