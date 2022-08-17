// ignore_for_file: file_names

class OfflinePushInfo {
  late String? title;
  late String? desc;
  String? ext;
  late bool? disablePush;
  late String? iOSSound;
  late bool? ignoreIOSBadge;
  late String? androidOPPOChannelID;
  late String? androidVIVOClassification;
  late String? androidSound;
  
  OfflinePushInfo({
    this.title,
    this.desc,
    this.disablePush,
    this.iOSSound,
    this.ignoreIOSBadge,
    this.androidOPPOChannelID,
    this.ext,
    this.androidSound,
    this.androidVIVOClassification,
  });

  OfflinePushInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    ext = json['ext'];
    disablePush = json['disablePush'];
    iOSSound = json['iOSSound'];
    ignoreIOSBadge = json['ignoreIOSBadge'];
    androidOPPOChannelID = json['AndroidOPPOChannelID'];
    androidSound = json['AndroidSound'];
    androidVIVOClassification = json['AndroidVIVOClassification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['desc'] = desc;
    data['ext'] = ext;
    data['disablePush'] = disablePush;
    data['iOSSound'] = iOSSound;
    data['ignoreIOSBadge'] = ignoreIOSBadge;
    data['androidOPPOChannelID'] = androidOPPOChannelID;
    data['androidSound'] = androidSound;
    data['androidVIVOClassification'] = androidVIVOClassification;
    return data;
  }
}
