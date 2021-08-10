import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'v2_tim_user_full_info.dart';

import 'dart:convert';

dynamic decode = json.decode;
dynamic encode = json.encode;

/// V2TimValueCallback
///
/// {@category Models}
///
class V2TimValueCallback<T> {
  late int code;
  late String desc;
  T? data;
  V2TimValueCallback({
    required this.code,
    required this.desc,
    this.data,
  });

  V2TimValueCallback.fromJson(Map<String, dynamic> json) {
    String tName = T.toString();
    late dynamic fromJsonData;
    if (json['data'] == null) {
      fromJsonData = this.data;
    } else {
      switch (tName) {
        case 'V2TimMessage':
          fromJsonData = V2TimMessage.fromJson(json['data']) as T;
          break;
        case 'V2TimUserFullInfo':
          fromJsonData = V2TimUserFullInfo.fromJson(json['data']) as T;
          break;
        case 'List<V2TimUserFullInfo>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimUserFullInfo.fromJson(e);
          }).toList() as T;
          break;
        case 'List<V2TimGroupInfo>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimGroupInfo.fromJson(e);
          }).toList() as T;
          break;
        case 'List<V2TimGroupInfoResult>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimGroupInfoResult.fromJson(e);
          }).toList() as T;
          break;
        case 'Map<String, String>':
          fromJsonData = new Map<String, String>.from(json['data']) as T;
          break;
        case 'V2TimGroupMemberInfoResult':
          fromJsonData = V2TimGroupMemberInfoResult.fromJson(json['data']) as T;
          break;
        case 'List<V2TimGroupMemberFullInfo>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimGroupMemberFullInfo.fromJson(e);
          }).toList() as T;
          break;
        case 'List<V2TimGroupMemberOperationResult>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimGroupMemberOperationResult.fromJson(e);
          }).toList() as T;
          break;
        case 'V2TimGroupApplicationResult':
          fromJsonData =
              V2TimGroupApplicationResult.fromJson(json['data']) as T;
          break;
        case 'V2TimConversationResult':
          fromJsonData = V2TimConversationResult.fromJson(json['data']) as T;
          break;
        case 'V2TimConversation':
          fromJsonData = V2TimConversation.fromJson(json['data']) as T;
          break;
        case 'List<V2TimFriendInfo>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimFriendInfo.fromJson(e);
          }).toList() as T;
          break;
        case 'List<V2TimFriendInfoResult>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimFriendInfoResult.fromJson(e);
          }).toList() as T;
          break;
        case 'V2TimFriendOperationResult':
          fromJsonData = V2TimFriendOperationResult.fromJson(json['data']) as T;
          break;
        case 'List<V2TimFriendOperationResult>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimFriendOperationResult.fromJson(e);
          }).toList() as T;
          break;
        case 'V2TimFriendCheckResult':
          fromJsonData = V2TimFriendCheckResult.fromJson(json['data']) as T;
          break;
        case 'List<V2TimFriendCheckResult>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimFriendCheckResult.fromJson(e);
          }).toList() as T;
          break;
        case 'V2TimFriendApplicationResult':
          fromJsonData =
              V2TimFriendApplicationResult.fromJson(json['data']) as T;
          break;
        case 'List<V2TimFriendGroup>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimFriendGroup.fromJson(e);
          }).toList() as T;
          break;
        case 'List<V2TimMessage>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimMessage.fromJson(e);
          }).toList() as T;
          break;
        case 'List<V2TimConversation>':
          fromJsonData = (json['data'] as List).map((e) {
            return V2TimConversation.fromJson(e);
          }).toList() as T;
          break;
        default:
          fromJsonData = json['data'];
      }
    }

    this.code = json['code'];
    this.desc = json['desc'] == null ? '' : json['desc'];
    this.data = fromJsonData;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    String tName = T.toString();
    data['code'] = this.code;
    data['desc'] = this.desc;
    dynamic toJsonData = this.data;
    if (this.data == null) {
      data['data'] = this.data;
    } else {
      switch (tName) {
        case 'V2TimMessage':
          toJsonData = (this.data as V2TimMessage).toJson();
          break;
        case 'V2TimUserFullInfo':
          toJsonData = (this.data as V2TimUserFullInfo).toJson();
          break;
        case 'List<V2TimUserFullInfo>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimUserFullInfo).toJson())
              .toList();
          break;
        case 'List<V2TimGroupInfo>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimGroupInfo).toJson())
              .toList();
          break;
        case 'List<V2TimGroupInfoResult>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimGroupInfoResult).toJson())
              .toList();
          break;
        case 'Map<String, String>':
          toJsonData = this.data as Map<String, String>;
          break;
        case 'V2TimGroupMemberInfoResult':
          toJsonData = (this.data as V2TimGroupMemberInfoResult).toJson();
          break;
        case 'List<V2TimGroupMemberFullInfo>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimGroupMemberFullInfo).toJson())
              .toList();
          break;
        case 'List<V2TimGroupMemberOperationResult>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimGroupMemberOperationResult).toJson())
              .toList();
          break;
        case 'V2TimGroupApplicationResult':
          toJsonData = (this.data as V2TimGroupApplicationResult).toJson();
          break;
        case 'V2TimConversationResult':
          toJsonData = (this.data as V2TimConversationResult).toJson();
          break;
        case 'V2TimConversation':
          toJsonData = (this.data as V2TimConversation).toJson();
          break;
        case 'List<V2TimFriendInfo>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimFriendInfo).toJson())
              .toList();
          break;
        case 'List<V2TimFriendInfoResult>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimFriendInfoResult).toJson())
              .toList();
          break;
        case 'V2TimFriendOperationResult':
          toJsonData = (this.data as V2TimFriendOperationResult).toJson();
          break;
        case 'List<V2TimFriendOperationResult>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimFriendOperationResult).toJson())
              .toList();
          break;
        case 'V2TimFriendCheckResult':
          toJsonData = (this.data as V2TimFriendCheckResult).toJson();
          break;
        case 'List<V2TimFriendCheckResult>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimFriendCheckResult).toJson())
              .toList();
          break;
        case 'V2TimFriendApplicationResult':
          toJsonData = (this.data as V2TimFriendApplicationResult).toJson();
          break;
        case 'List<V2TimFriendGroup>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimFriendGroup).toJson())
              .toList();
          break;
        case 'List<V2TimMessage>':
          toJsonData = (this.data as List)
              .map((e) => (e as V2TimMessage).toJson())
              .toList();
          break;
        default:
          toJsonData = this.data;
      }
      data['data'] = toJsonData;
    }
    return data;
  }
}
