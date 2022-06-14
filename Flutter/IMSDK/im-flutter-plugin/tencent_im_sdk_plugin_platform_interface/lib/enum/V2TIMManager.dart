// ignore_for_file: prefer_function_declarations_over_variables, file_names

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
