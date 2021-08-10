/// V2TimLocationElem
///
/// {@category Models}
///
class V2TimLocationElem {
  late String? desc;
  late double longitude;
  late double latitude;

  V2TimLocationElem(
      {this.desc, required this.longitude, required this.latitude});

  V2TimLocationElem.fromJson(Map<String, dynamic> json) {
    desc = json['desc'];
    longitude = json['longitude'];
    latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['desc'] = this.desc;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    return data;
  }
}

// {
//   "desc":"",
//   "longitude":0.0,
// "latitude":0.0
// }
