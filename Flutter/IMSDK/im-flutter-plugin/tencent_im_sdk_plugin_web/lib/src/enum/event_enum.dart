// ignore_for_file: non_constant_identifier_names

import 'package:js/js.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

@JS("TIM")
class EventEnum {
  external static dynamic EVENT; // 这个是用作枚举的
}

class EventType {
  static String MESSAGE_RECEIVED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['MESSAGE_RECEIVED'], "onMessageReceived");
  static String MESSAGE_MODIFIED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['MESSAGE_MODIFIED'], "onMessageModified");
  static String MESSAGE_READ_BY_PEER = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['MESSAGE_READ_BY_PEER'],
      "onMessageReadByPeer");
  static String MESSAGE_READ_RECEIPT_RECEIVED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['MESSAGE_READ_RECEIPT_RECEIVED'],
      "onMessageReadReceiptReceived");
  static String MESSAGE_REVOKED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['MESSAGE_REVOKED'], "onMessageRevoked");
  static String GROUP_ATTRIBUTES_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['GROUP_ATTRIBUTES_UPDATED'],
      "groupAttributesUpdated");
  static String GROUP_LIST_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['GROUP_LIST_UPDATED'],
      "onGroupListUpdated");

  static String TOPIC_CREATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['TOPIC_CREATED'], "onTopicCreated");
  static String TOPIC_DELETED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['TOPIC_DELETED'], "onTopicDeleted");
  static String TOPIC_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['TOPIC_UPDATED'], "onTopicUpdated");

  // 好友和自己的资料变更(native自己和好友是分开的)
  static String PROFILE_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['PROFILE_UPDATED'], "onProfileUpdated");

  static String SDK_READY = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['SDK_READY'], "sdkStateReady");

  static String KICKED_OUT =
      checkEmptyEnum(() => jsToMap(EventEnum.EVENT)['KICKED_OUT'], "kickedOut");

  static String CONVERSATION_LIST_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['CONVERSATION_LIST_UPDATED'],
      "onConversationListUpdated");

  // Friend
  // 好友和自己的资料变更
  static String FRIEND_LIST_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['FRIEND_LIST_UPDATED'],
      "onFriendListUpdated");

  // 黑名单变更
  static String BLACKLIST_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['BLACKLIST_UPDATED'], "blacklistUpdated");
  // 好友申请变更
  static String FRIEND_APPLICATION_LIST_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['FRIEND_APPLICATION_LIST_UPDATED'],
      "onFriendApplicationListUpdated");
  // 好友分组变更回调（navite中没有用到，暂不使用）
  static String FRIEND_GROUP_LIST_UPDATED = checkEmptyEnum(
      () => jsToMap(EventEnum.EVENT)['FRIEND_GROUP_LIST_UPDATED'],
      "onFriendGroupListUpdated");
}
