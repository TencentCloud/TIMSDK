typedef SetAPPUnreadCountCallback = void Function(int unreadCount);

class V2TIMAPNSListener {
  SetAPPUnreadCountCallback onSetAPPUnreadCount = (int unreadCount) {};
  V2TIMAPNSListener({
    SetAPPUnreadCountCallback? onSetAPPUnreadCount,
  }) {
    if (onSetAPPUnreadCount != null) {
      this.onSetAPPUnreadCount = onSetAPPUnreadCount;
    }
  }
}
