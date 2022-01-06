import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

final genderMapping = <String, dynamic>{
  'Gender_Type_Female': 2,
  'Gender_Type_Male': 1,
  'Gender_Type_Unknown': 0
};

final allowTypeMapping = <String, dynamic>{
  'AllowType_Type_AllowAny': 0,
  'AllowType_Type_NeedConfirm': 1,
  'AllowType_Type_DenyAny': 2
};

class V2TimProfile {
  static Object formateSetSelfInfoParams(Map<String, dynamic> params) {
    final fomatedParams = <String, dynamic>{
      "nick": params["nickName"],
      "avatar": params["faceUrl"],
      "gender": convertGenderFromDartToWeb(params["gender"]),
      "selfSignature": params["selfSignature"],
      "allowType": convertAllowTypeFromDartToWeb(params['allowType']),
      "level": params["level"] ?? 0,
      "role": params["role"] ?? 0,
      "profileCustomField":
          convertCustomInfoFromDartToWeb(params['customInfo']),
    };
    return mapToJSObj(fomatedParams);
  }

  static Map<String, dynamic> userFullInfoExtract(
      Map<String, dynamic> profile) {
    return <String, dynamic>{
      'userID': profile['userID'],
      'faceUrl': profile['avatar'],
      'allowType': convertAllowTypeFromWebToDart(profile['allowType']),
      'nickName': profile['nick'],
      'selfSignature': profile['selfSignature'],
      'gender': convertGenderFromWebToDart(profile['gender']),
      'role': profile['role'],
      'level': profile['level'],
      'customInfo':
          convertCustomInfoFromWebToDart(profile['profileCustomField'])
    };
  }

  static dynamic convertCustomInfoFromWebToDart(List customInfo) {
    final profileCustomInfo = {};
    for (var element in customInfo) {
      final mapElement = jsToMap(element);
      final customInfoKey = mapElement['key'].split('Tag_Profile_Custom_')[1];
      profileCustomInfo[customInfoKey] = mapElement['value'];
    }
    return profileCustomInfo;
  }

  static dynamic convertCustomInfoFromDartToWeb(
      Map<String, dynamic> customInfo) {
    final profileCustomInfo = customInfo.keys.map((k) =>
        mapToJSObj({'key': 'Tag_Profile_Custom_' + k, 'value': customInfo[k]}));

    return profileCustomInfo.toList();
  }

  static dynamic convertGenderFromWebToDart(String gender) {
    return genderMapping[gender];
  }

  static dynamic convertGenderFromDartToWeb(int gender) {
    return genderMapping.keys.firstWhere(
        (element) => genderMapping[element] == gender,
        orElse: () => '');
  }

  static dynamic convertAllowTypeFromWebToDart(String allowType) {
    return allowTypeMapping[allowType];
  }

  static dynamic convertAllowTypeFromDartToWeb(int allowType) {
    return allowTypeMapping.keys.firstWhere(
        (element) => allowTypeMapping[element] == allowType,
        orElse: () => '');
  }
}
