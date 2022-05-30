// ignore_for_file: file_names

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['desc'] = desc;
    data['disablePush'] = disablePush;
    data['ext'] = ext;
    data['iOSSound'] = iOSSound;
    data['ignoreIOSBadge'] = ignoreIOSBadge;
    data['androidOPPOChannelID'] = androidOPPOChannelID;
    return data;
  }
}
