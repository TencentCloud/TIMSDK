class OfflinePushInfo {
  late String title;
  late String desc;
  late bool disablePush;
  late String ext;
  late String iOSSound;
  late bool ignoreIOSBadge;
  late String androidOPPOChannelID;

  OfflinePushInfo({
    this.title = '',
    this.desc = '',
    this.disablePush = false,
    this.ext = '',
    this.iOSSound = '',
    this.ignoreIOSBadge = false,
    this.androidOPPOChannelID = '',
  });

  OfflinePushInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    disablePush = json['disablePush'];
    ext = json['ext'];
    iOSSound = json['iOSSound'];
    ignoreIOSBadge = json['ignoreIOSBadge'];
    androidOPPOChannelID = json['androidOPPOChannelID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['disablePush'] = this.disablePush;
    data['ext'] = this.ext;
    data['iOSSound'] = this.iOSSound;
    data['ignoreIOSBadge'] = this.ignoreIOSBadge;
    data['androidOPPOChannelID'] = this.androidOPPOChannelID;
    return data;
  }
}
