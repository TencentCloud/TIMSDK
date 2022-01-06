import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_result_item.dart';

/// V2TimMessageSearchResult
///
/// {@category Models}
///
class V2TimMessageSearchResult {
  int? totalCount;
  List<V2TimMessageSearchResultItem>? messageSearchResultItems;

  V2TimMessageSearchResult({
    this.totalCount,
    this.messageSearchResultItems,
  });

  V2TimMessageSearchResult.fromJson(Map<String, dynamic> json) {
    this.totalCount = json['totalCount'];
    if (json['messageSearchResultItems'] != null) {
      messageSearchResultItems = List.empty(growable: true);
      json['messageSearchResultItems'].forEach((v) {
        messageSearchResultItems!
            .add(new V2TimMessageSearchResultItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    if (this.messageSearchResultItems != null) {
      data['messageSearchResultItems'] =
          this.messageSearchResultItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// {
//   "userID":"",
//   "timestamp":0
// }
