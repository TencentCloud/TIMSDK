// ignore_for_file: avoid_print

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/event_enum.dart';
import 'package:tencent_im_sdk_plugin_web/src/manager/im_sdk_plugin_js.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_delete_conversation.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_get_conversation.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_get_conversation_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_pin_conversation.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class V2TIMConversationManager {
  late TIM? timeweb;
  static V2TimConversationListener? _conversationListener;

  V2TIMConversationManager() {
    timeweb = V2TIMManagerWeb.timWeb;
  }

  static final _conversationListenerWeb = allowInterop((res) async {
    List<dynamic> conversationList =
        await GetConversationList.formateConversationList(jsToMap(res)['data']);
    final convList =
        conversationList.map((e) => V2TimConversation.fromJson(e)).toList();
    _conversationListener?.onConversationChanged(convList);
  });

/*
  注意：web只有一个update回调(新增也在里面)，这个回调不做初始化磨平操作，native有新的会话
  即会在初始化时调用这个监听
*/
  void setConversationListener(V2TimConversationListener listener) async {
    _conversationListener = listener;
    timeweb!.on(EventType.CONVERSATION_LIST_UPDATED, _conversationListenerWeb);
  }

  void makeConversationListenerEventData(_channel, String type, data) {
    CommonUtils.emitEvent(_channel, "conversationListener", type, data);
  }

  // web 中参数无法传递分页信息
  Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationList() async {
    // try {
    final res = await wrappedPromiseToFuture(timeweb!.getConversationList());
    List<dynamic> conversationList =
        await GetConversationList.formateConversationList(
            jsToMap(res.data)['conversationList']);
    return CommonUtils.returnSuccess<V2TimConversationResult>(
        GetConversationList.formatReturn(conversationList));
    // } catch (error) {
    //   return CommonUtils.returnErrorForValueCb<V2TimConversationResult>(
    //       error.toString());
    // }
  }

  // 和getConversationList 调用的是相同的方法, 此项接口返回的数据没有getConversationProfile全
  Future<dynamic> getConversationListByConversaionIds(param) async {
    try {
      var res = await wrappedPromiseToFuture(
          timeweb!.getConversationList(param["conversationIDList"]));
      var conversationList = await GetConversationList.formateConversationList(
          jsToMap(res.data)['conversationList']);
      return CommonUtils.returnSuccess<List<V2TimConversation>>(
          conversationList);
    } catch (err) {
      return CommonUtils.returnErrorForValueCb<List<V2TimConversation>>(err);
    }
  }

  // web中的方法名字是： getConversationProfile
  Future<dynamic> getConversation(conversationParams) async {
    try {
      var res = await wrappedPromiseToFuture(timeweb!.getConversationProfile(
          GetConversation.formateParams(conversationParams)));

      return CommonUtils.returnSuccess<V2TimConversation>(
          await GetConversationList.formateConversationListItem(
              jsToMap(jsToMap(res.data)['conversation'])));
    } catch (err) {
      return CommonUtils.returnErrorForValueCb<V2TimConversation>(err);
    }
  }

  Future<dynamic> deleteConversation(conversationParams) async {
    try {
      await promiseToFuture(timeweb!.deleteConversation(
          DeleteConversation.formateParams(conversationParams)));

      return CommonUtils.returnSuccessWithDesc('ok');
    } catch (err) {
      return CommonUtils.returnError(err.toString());
    }
  }

  Future<dynamic> pinConversation(params) async {
    try {
      final formatedParams = PinConversation.formateParams(params);
      final res =
          await promiseToFuture(timeweb!.pinConversation(formatedParams));
      return CommonUtils.returnSuccessForCb(jsToMap(res)['conversationID']);
    } catch (err) {
      return CommonUtils.returnError(err);
    }
  }

  // web不存在添加草稿功能
  Future<dynamic> setConversationDraft() async {
    print("web不支持添加草稿功能");
    return CommonUtils.returnError(
        "setConversationDraft feature does not exist on the web");
  }

  // web不存在获得未读消息总数此功能
  Future<dynamic> getTotalUnreadMessageCount() async {
    print("web不支持获得未读消息总数此功能");
    return CommonUtils.returnErrorForValueCb<int>(
        "getTotalUnreadMessageCount feature does not exist on the web");
  }

  Future<void> removeConversationListener({
    String? listenerUuid,
  }) async {
    timeweb!.off(EventType.CONVERSATION_LIST_UPDATED, _conversationListenerWeb);
  }
}
