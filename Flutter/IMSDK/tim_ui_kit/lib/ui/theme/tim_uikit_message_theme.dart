import 'package:flutter/material.dart';

class MessageThemeData {
  /// Text style for message text
  final TextStyle? messageTextStyle;

  /// Text style for user nick name
  final TextStyle? nickNameTextStyle;

  /// Text style for timeline
  final TextStyle? timelineTextStyle;

  /// Color for messageBackgroundColor
  final Color? messageBackgroundColor;

  /// border radius for text message
  final BorderRadius? messageBorderRadius;

  final BorderRadius? avatarBorderRadius;

  MessageThemeData({
    this.messageTextStyle,
    this.messageBackgroundColor,
    this.messageBorderRadius,
    this.nickNameTextStyle,
    this.timelineTextStyle,
    this.avatarBorderRadius,
  });
}
