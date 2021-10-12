import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'v2_tim_group_member_full_info.dart';

/// V2TimMessageSearchResult
///
/// {@category Models}
///
class V2GroupMemberInfoSearchResult {
  Map<String, dynamic>? groupMemberSearchResultItems;

  V2GroupMemberInfoSearchResult({
    this.groupMemberSearchResultItems,
  });

  V2GroupMemberInfoSearchResult.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> myMap = {};
    json.forEach((key, value) {
      var tempArr = [];
      if (value is List) {
        value.forEach((element) {
          tempArr.add(V2TimGroupMemberFullInfo.fromJson(element));
        });
        myMap[key] = tempArr;
      }
    });
    groupMemberSearchResultItems = myMap;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.groupMemberSearchResultItems != null) {
      var map = this.groupMemberSearchResultItems;
      var newMap = {};
      map?.forEach((key, value) {
        newMap[key] = value.map((v) => v.toJson()).toList();
      });
      data['messageSearchResultItems'] = newMap;
    }
    return data;
  }
}
