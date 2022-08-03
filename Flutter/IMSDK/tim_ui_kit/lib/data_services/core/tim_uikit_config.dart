class TIMUIKitConfig {
  /// Control if show online status of friends or contacts.
  /// This only works with [Ultimate Edition].
  /// [Default]: true.
  final bool isShowOnlineStatus;

  const TIMUIKitConfig({
    this.isShowOnlineStatus = true,
  });
}