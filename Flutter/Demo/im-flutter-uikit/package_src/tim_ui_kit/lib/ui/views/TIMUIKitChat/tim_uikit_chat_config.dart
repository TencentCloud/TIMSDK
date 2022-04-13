class TIMUIKitChatConfig {

  /// 控制是否展示消息已读未读状态
  final bool isShowReadingStatus;

  /// 控制是否允许呼出长按消息功能菜单
  final bool isAllowLongPressMessage;

  /// 控制是否允许聊天中点击用户头像
  final bool isAllowClickAvatar;

  /// 控制是否允许发送表情消息
  final bool isAllowEmojiPanel;

  /// 控制是否展示加号更多消息能力面板
  final bool isAllowShowMorePanel;

  /// 控制是否允许发送语音消息
  final bool isAllowSoundMessage;

  /// 控制是否引用消息时同时AT对方，参考：目前企业微信有此特性/微信没有此特性
  final bool isAtWhenReply;

  const TIMUIKitChatConfig({
    this.isAtWhenReply = true,
    this.isAllowSoundMessage = true,
    this.isAllowEmojiPanel = true,
    this.isAllowShowMorePanel = true,
    this.isShowReadingStatus = true,
    this.isAllowLongPressMessage = true,
    this.isAllowClickAvatar = true,
  });
}
