class TIMUIKitConfig {
  /// Control if show online status of friends or contacts.
  /// This only works with [Ultimate Edition].
  /// [Default]: true.
  final bool isShowOnlineStatus;

  /// Controls if allows to check the disk memory after login.
  /// If the storage space is less than 1GB,
  /// an callback from `onTUIKitCallbackListener` will be invoked,
  /// type is `INFO`, while code is 6661403.
  final bool isCheckDiskStorageSpace;

  const TIMUIKitConfig({
    this.isCheckDiskStorageSpace = true,
    this.isShowOnlineStatus = true,
  });
}
