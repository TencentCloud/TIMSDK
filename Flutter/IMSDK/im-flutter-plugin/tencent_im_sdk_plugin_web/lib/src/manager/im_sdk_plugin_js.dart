// @JS()

// library tim;

// ignore_for_file: unused_import, non_constant_identifier_names

import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'dart:js' as js;

import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_init_sdk.dart';

// 此为为自定义JS库实验性质，后面我会清除
// @JS("ImWrapper")
// class ImWrapper {
//   external ImWrapper();
//   external int create(param);
//   external void test();
// }

@JS("TIMUploadPlugin")
class TIMUploadPlugin {
  external TIMUploadPlugin();
}

// 引入TIM JS库
@JS("TIM")
class TIM {
  external static dynamic create(param);
  external static String VERSION;

  external void on(String enumValue, fun);
  external void off(String enumValue, fun);

  external Future login(param);
  external Future logout();
  external Future getMyProfile();
  external Future getUserProfile(param);
  external Future updateMyProfile(param);
  external destroy();

  // group releated call
  external Future createGroup(param);

  external Future getConversationList([param]);
  external Future getMessageList(param);
  external Future setMessageRead(param);
  external Future getConversationProfile(param);
  external Future deleteConversation(param);
  external Future pinConversation(param);
  external Future getGroupList();
  external Future joinGroup(param);
  external Future quitGroup(param);
  external Future dismissGroup(param);

  // friendship releated call
  external Future getFriendList();
  external Future getFriendProfile(param);
  external Future addFriend(param);
  external Future updateFriend(param);
  external Future deleteFriend(param);
  external Future checkFriend(param);
  external Future getFriendApplicationList();
  external Future acceptFriendApplication(param);
  external Future refuseFriendApplication(param);
  external Future deleteFriendApplication(param);
  external Future setFriendApplicationRead();
  external Future addToBlacklist(param);
  external Future removeFromBlacklist(param);
  external Future getBlacklist();
  external Future getFriendGroupList();
  external Future createFriendGroup(param);
  external Future deleteFriendGroup(param);
  external Future addToFriendGroup(param);
  external Future removeFromFriendGroup(param);
  external Future renameFriendGroup(param);
  external Future addFriendsToFriendGroup(param);
  external Future deleteFriendsFromFriendGroup(param);

  // message
  external createTextMessage(param);
  external createCustomMessage(param);
  external createImageMessage(params);
  external createTextAtMessage(params);
  external createLocationMessage(params);
  external createMergerMessage(params);
  external createForwardMessage(params);
  external createVideoMessage(params);
  external createFileMessage(params);
  external createFaceMessage(params);
  external Future revokeMessage(params);
  external Future sendMessage(param, [param2]);
  external Future reSendMessage(param);
  external Future deleteMessages(param);
  external Future setMessageRemindType(param);

  // group
  external Future getGroupProfile(poaram);
  external Future updateGroupProfile(param);
  external Future getGroupOnlineMemberCount(param);
  external Future getGroupMemberList(param);
  external Future getGroupMemberProfile(param);
  external Future setGroupMemberNameCard(param);
  external Future setGroupMemberCustomField(param);
  external Future setGroupMemberMuteTime(param);
  external Future addGroupMember(param);
  external Future deleteGroupMember(param);
  external Future setGroupMemberRole(param);
  external Future changeGroupOwner(param);
  external Future setGroupAttributes(param);
  external Future deleteGroupAttributes(param);
  external Future getGroupAttributes(param);
  external Future handleGroupApplication(param);
  external Future searchGroupByID(param);
  external registerPlugin(param);
}

initTim(options) {
  return TIM.create(options);
}

String getVersion() => TIM.VERSION;

// 做TIM的初始化,timWeb是一个动态的duynamic（即JS的object）
class V2TIMManagerWeb {
  static dynamic timWeb;

  static setTimWeb(myTimWeb) async {
    timWeb = myTimWeb;
  }

  static dynamic initWebTim(TimParams params) {
    timWeb = initTim(params);
    timWeb!.registerPlugin(mapToJSObj({
      'tim-upload-plugin': allowInterop(() {
        return TIMUploadPlugin();
      })
    }));
  }

  static String getWebSDKVersion() => getVersion();
}
