import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_elem.dart';

/// V2TimLocationElem
///
/// {@category Models}
///
class V2TimLocationElem extends V2TIMElem {
  late String? desc;
  late double longitude;
  late double latitude;

  V2TimLocationElem(
      {this.desc, required this.longitude, required this.latitude});

  V2TimLocationElem.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['desc'] = desc;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}

// {
//   "desc":"",
//   "longitude":0.0,
// "latitude":0.0
// }
