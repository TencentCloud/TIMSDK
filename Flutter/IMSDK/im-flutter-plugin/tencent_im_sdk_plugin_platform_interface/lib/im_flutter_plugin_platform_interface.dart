// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/history_message_get_type.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/method_channel_im_flutter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/V2_tim_topic_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversationList_filter.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_friend_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_message_read_member_list.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_change_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_param.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_topic_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_status.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'enum/V2TimSDKListener.dart';

abstract class ImFlutterPlatform extends PlatformInterface {
  ImFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static ImFlutterPlatform _instance = MethodChannelIm();

  static ImFlutterPlatform get instance => _instance;

  static set instance(ImFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /*****************************-基础模块-***********************************/
  /*

                      :;J7, :,                        ::;7:
                      ,ivYi, ,                       ;LLLFS:
                      :iv7Yi                       :7ri;j5PL
                     ,:ivYLvr                    ,ivrrirrY2X,
                     :;r@Wwz.7r:                :ivu@kexianli.
                    :iL7::,:::iiirii:ii;::::,,irvF7rvvLujL7ur
                   ri::,:,::i:iiiiiii:i:irrv177JX7rYXqZEkvv17
                ;i:, , ::::iirrririi:i:::iiir2XXvii;L8OGJr71i
              :,, ,,:   ,::ir@mingyi.irii:i:::j1jri7ZBOS7ivv,
                 ,::,    ::rv77iiiriii:iii:i::,rvLq@huhao.Li
             ,,      ,, ,:ir7ir::,:::i;ir:::i:i::rSGGYri712:
           :::  ,v7r:: ::rrv77:, ,, ,:i7rrii:::::, ir7ri7Lri
          ,     2OBBOi,iiir;r::        ,irriiii::,, ,iv7Luur:
        ,,     i78MBBi,:,:::,:,  :7FSL: ,iriii:::i::,,:rLqXv::
        :      iuMMP: :,:::,:ii;2GY7OBB0viiii:i:iii:i:::iJqL;::
       ,     ::::i   ,,,,, ::LuBBu BBBBBErii:i:i:i:i:i:i:r77ii
      ,       :       , ,,:::rruBZ1MBBqi, :,,,:::,::::::iiriri:
     ,               ,,,,::::i:  @arqiao.       ,:,, ,:::ii;i7:
    :,       rjujLYLi   ,,:::::,:::::::::,,   ,:i,:,,,,,::i:iii
    ::      BBBBBBBBB0,    ,,::: , ,:::::: ,      ,,,, ,,:::::::
    i,  ,  ,8BMMBBBBBBi     ,,:,,     ,,, , ,   , , , :,::ii::i::
    :      iZMOMOMBBM2::::::::::,,,,     ,,,,,,:,,,::::i:irr:i:::,
    i   ,,:;u0MBMOG1L:::i::::::  ,,,::,   ,,, ::::::i:i:iirii:i:i:
    :    ,iuUuuXUkFu7i:iii:i:::, :,:,: ::::::::i:i:::::iirr7iiri::
    :     :rk@Yizero.i:::::, ,:ii:::::::i:::::i::,::::iirrriiiri::,
     :      5BMBBBBBBSr:,::rv2kuii:::iii::,:i:,, , ,,:,:i@petermu.,
          , :r50EZ8MBBBBGOBBBZP7::::i::,:::::,: :,:,::i;rrririiii::
              :jujYY7LS0ujJL7r::,::i::,::::::::::::::iirirrrrrrr:ii:
           ,:  :@kevensun.:,:,,,::::i:i:::::,,::::::iir;ii;7v77;ii;i,
           ,,,     ,,:,::::::i:iiiii:i::::,, ::::iiiir@xingjief.r;7:i,
        , , ,,,:,,::::::::iiiiiiiiii:,:,:::::::::iiir;ri7vL77rrirri::
         :,, , ::::::::i:::i:::i:i::,,,,,:,::i:i::用于区分不同模块比较方便
  */

  /// 初始化SDK
  ///
  /// 参数
  ///
  /// ```
  /// @required int sdkAppID	应用 ID，必填项，可以在控制台中获取
  /// @required int loglevel	配置信息
  /// @required [InitListener] listener	SDK的回调
  /// ```
  ///
  /// 返回
  /// ```
  /// true：成功；
  /// false：失败
  /// ```
  Future<V2TimValueCallback<bool>> initSDK({
    required int sdkAppID,
    required int loglevel,
    String? listenerUuid,
    V2TimSDKListener? listener,
    required String uiPlatform,
  }) {
    throw UnimplementedError('initSDK() has not been implemented.');
  }

  ///反初始化 SDK
  ///
  Future<V2TimCallback> unInitSDK() {
    throw UnimplementedError('unInitSDK() has not been implemented.');
  }

  /// 获取版本号
  ///
  Future<V2TimValueCallback<String>> getVersion() {
    throw UnimplementedError('getVersion() has not been implemented.');
  }

  /// 获取服务器当前时间
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<int>> getServerTime() {
    throw UnimplementedError('getServerTime() has not been implemented.');
  }

  /// 登录
  ///
  /// 参数
  ///
  /// ```
  /// @required String userID,
  /// @required String userSig,
  /// ```
  ///
  /// ```
  /// 登录需要设置用户名 userID 和用户签名 userSig，userSig 生成请参考 UserSig 后台 API。
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 登陆时票据过期：login 函数的回调会返回 ERR_USER_SIG_EXPIRED：6206 错误码，此时生成新的 userSig 重新登录。
  /// 在线时票据过期：用户在线期间也可能收到 V2TIMListener -> onUserSigExpired 回调，此时也是需要您生成新的 userSig 并重新登录。
  /// 在线时被踢下线：用户在线情况下被踢，SDK 会通过 V2TIMListener -> onKickedOffline 回调通知给您，此时可以 UI 提示用户，并再次调用 login() 重新登录。
  /// ```

  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) {
    throw UnimplementedError('login() has not been implemented.');
  }

  /// 登出
  ///
  ///```
  /// 退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
  ///```
  Future<V2TimCallback> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  /// 发送单聊普通文本消息（最大支持 8KB）
  ///
  /// ```
  /// 文本消息支持云端的脏词过滤，如果用户发送的消息中有敏感词，callback 回调将会返回 80001 错误码。
  /// ```
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认会推送（前提是在 V2TIMOfflinePushManager 开启了推送），如果需要自定义推送（标题和内容），请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage({
    required String text,
    required String userID,
  }) async {
    throw UnimplementedError('sendC2CTextMessage() has not been implemented.');
  }

  /// 发送单聊自定义（信令）消息（最大支持 8KB）
  ///
  /// ```
  /// 自定义消息本质就是一端二进制 buffer，您可以在其上自由组织自己的消息格式（常用于发送信令），但是自定义消息不支持云端敏感词过滤。
  /// ```
  ///
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  /// ```
  /// 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMMessageManager.sendMessage 接口。
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendC2CCustomMessage({
    required String customData,
    required String userID,
  }) async {
    throw UnimplementedError(
        'sendC2CCustomMessage() has not been implemented.');
  }

  /// 发送群聊普通文本消息（最大支持 8KB）
  ///
  /// 参数
  ///
  /// ```
  /// priority	设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
  /// V2TIMMessage.V2TIM_PRIORITY_HIGH = 1：云端会优先传输，适用于在群里发送重要消息，比如主播发送的文本消息等。
  /// V2TIMMessage.V2TIM_PRIORITY_NORMAL = 2：云端按默认优先级传输，适用于在群里发送非重要消息，比如观众发送的弹幕消息等。
  /// ```
  ///
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认会推送（前提是在 V2TIMOfflinePushManager 开启了推送），如果需要自定义推送（标题和内容），请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  Future<V2TimValueCallback<V2TimMessage>> sendGroupTextMessage({
    required String text,
    required String groupID,
    int priority = 0,
  }) async {
    throw UnimplementedError(
        'sendGroupTextMessage() has not been implemented.');
  }

  /// 发送群聊自定义（信令）消息（最大支持 8KB）
  ///
  /// 参数
  ///
  /// ```
  /// priority	设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
  /// V2TIMMessage.V2TIM_PRIORITY_HIGH = 1：云端会优先传输，适用于在群里发送重要信令，比如连麦邀请，PK邀请、礼物赠送等关键性信令。
  /// V2TIMMessage.V2TIM_PRIORITY_NORMAL = 2：云端按默认优先级传输，适用于在群里发送非重要信令，比如观众的点赞提醒等等。
  /// ```
  /// 返回
  ///
  /// ```
  /// 返回消息的唯一标识 ID
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 该接口发送的消息默认不会推送，如果需要推送，请调用 V2TIMMessageManager.sendMessage 接口。
  /// ```
  Future<V2TimValueCallback<V2TimMessage>> sendGroupCustomMessage({
    required String customData,
    required String groupID,
    int priority = 0,
  }) async {
    throw UnimplementedError(
        'sendGroupCustomMessage() has not been implemented.');
  }

  /// 获取登录用户
  ///
  Future<V2TimValueCallback<String>> getLoginUser() async {
    throw UnimplementedError('getLoginUser() has not been implemented.');
  }

  /// 获取登录状态
  ///
  ///```
  /// 如果用户已经处于已登录和登录中状态，请勿再频繁调用登录接口登录。
  /// ```
  ///
  /// 返回
  ///
  ///```
  /// 登录状态
  /// V2TIM_STATUS_LOGINED 已登录
  /// V2TIM_STATUS_LOGINING 登录中
  /// V2TIM_STATUS_LOGOUT 无登录
  /// ```
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<int>> getLoginStatus() async {
    throw UnimplementedError('getLoginStatus()  has not been implemented.');
  }

  /// 获取用户资料
  ///
  /// 注意
  ///
  /// ```
  /// 获取自己的资料，传入自己的 ID 即可。
  /// userIDList 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// ```
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    throw UnimplementedError('getUsersInfo() has not been implemented.');
  }

  /// 创建群组
  ///
  ///参数
  ///```
  /// groupType	群类型，我们为您预定义好了四种常用的群类型，您也可以在控制台定义自己需要的群类型：
  ///
  ///   "Work" ：工作群，成员上限 200 人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。
  ///
  ///   "Public" ：公开群，成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。
  ///
  ///   "Meeting" ：会议群，成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。
  ///
  ///   "AVChatRoom" ：直播群，人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。
  ///
  /// groupID	自定义群组 ID，可以传 null。传 null 时系统会自动分配 groupID，并通过 callback 返回。
  ///
  /// groupName	群名称，不能为 null。
  ///```
  /// 注意
  ///
  ///```
  /// 不支持在同一个 SDKAPPID 下创建两个相同 groupID 的群
  ///   /// info	自定义群组信息，可以设置 groupID | groupType | groupName | notification | introduction | faceURL 字段
  /// memberList	指定初始的群成员（直播群 AVChatRoom 不支持指定初始群成员，memberList 请传 null）
  /// ```
  Future<V2TimValueCallback<String>> createGroup({
    String? groupID,
    required String groupType,
    required String groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    bool? isAllMuted,
    int? addOpt,
    List<V2TimGroupMember>? memberList,
    bool? isSupportTopic,
  }) async {
    throw UnimplementedError('createGroup() has not been implemented.');
  }

  /// 加入群组
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：不能主动入群，只能通过群成员调用 V2TIMManager.getGroupManager().inviteUserToGroup() 接口邀请入群。
  /// 公开群（Public）：申请入群后，需要管理员审批，管理员在收到 V2TIMGroupListener -> onReceiveJoinApplication 回调后调用 V2TIMManager.getGroupManager().getGroupApplicationList() 接口处理加群请求。
  /// 其他群：可以直接入群。
  /// 注意：当在web端时，加入直播群时groupType字段必填
  /// ```
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    throw UnimplementedError('joinGroup() has not been implemented.');
  }

  /// 退出群组
  ///
  /// 注意
  ///
  /// ```
  /// 在公开群（Public）、会议（Meeting）和直播群（AVChatRoom）中，群主是不可以退群的，群主只能调用 dismissGroup 解散群组。
  /// ``
  Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    throw UnimplementedError('quitGroup() has not been implemented.');
  }

  /// 解散群组
  ///
  /// 注意
  ///
  /// ```
  /// Work：任何人都无法解散群组。
  /// 其他群：群主可以解散群组。
  /// ```
  Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    throw UnimplementedError('dismissGroup() has not been implemented.');
  }

  /// 修改个人资料
  ///
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    throw UnimplementedError('setSelfInfo() has not been implemented.');
  }

  /// 实验性 API 接口
  ///
  /// 参数
  /// api	接口名称
  /// param	接口参数
  // 注意
  /// 该接口提供一些实验性功能
  ///
  /// 注意：web不支持该接口
  ///
  Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    throw UnimplementedError('callExperimentalAPI() has not been implemented');
  }

  /// 设置基本消息（文本消息和自定义消息）的事件监听器
  ///
  /// 注意
  ///
  /// ```
  /// 图片消息、视频消息、语音消息等高级消息的监听，请参考: V2TIMMessageManager.addAdvancedMsgListener(V2TIMAdvancedMsgListener) 。
  /// ```
  Future<void> addSimpleMsgListener({
    required V2TimSimpleMsgListener listener,
    String? listenerUuid,
  }) async {
    throw UnimplementedError('addSimpleMsgListener() has not been implemented');
  }

  /// 移除基本消息（文本消息和自定义消息）的事件监听器
  ///
  Future<void> removeSimpleMsgListener({
    String? listenerUuid,
  }) async {
    throw UnimplementedError(
        'removeSimpleMsgListener() has not been implemented');
  }

  /// 设置apns监听
  ///
  Future setAPNSListener() async {
    throw UnimplementedError('setAPNSListener() has not been implemented');
  }

  /// ***************************-会话模块-***********************************/
  /*

                      :;J7, :,                        ::;7:
                      ,ivYi, ,                       ;LLLFS:
                      :iv7Yi                       :7ri;j5PL
                     ,:ivYLvr                    ,ivrrirrY2X,
                     :;r@Wwz.7r:                :ivu@kexianli.
                    :iL7::,:::iiirii:ii;::::,,irvF7rvvLujL7ur
                   ri::,:,::i:iiiiiii:i:irrv177JX7rYXqZEkvv17
                ;i:, , ::::iirrririi:i:::iiir2XXvii;L8OGJr71i
              :,, ,,:   ,::ir@mingyi.irii:i:::j1jri7ZBOS7ivv,
                 ,::,    ::rv77iiiriii:iii:i::,rvLq@huhao.Li
             ,,      ,, ,:ir7ir::,:::i;ir:::i:i::rSGGYri712:
           :::  ,v7r:: ::rrv77:, ,, ,:i7rrii:::::, ir7ri7Lri
          ,     2OBBOi,iiir;r::        ,irriiii::,, ,iv7Luur:
        ,,     i78MBBi,:,:::,:,  :7FSL: ,iriii:::i::,,:rLqXv::
        :      iuMMP: :,:::,:ii;2GY7OBB0viiii:i:iii:i:::iJqL;::
       ,     ::::i   ,,,,, ::LuBBu BBBBBErii:i:i:i:i:i:i:r77ii
      ,       :       , ,,:::rruBZ1MBBqi, :,,,:::,::::::iiriri:
     ,               ,,,,::::i:  @arqiao.       ,:,, ,:::ii;i7:
    :,       rjujLYLi   ,,:::::,:::::::::,,   ,:i,:,,,,,::i:iii
    ::      BBBBBBBBB0,    ,,::: , ,:::::: ,      ,,,, ,,:::::::
    i,  ,  ,8BMMBBBBBBi     ,,:,,     ,,, , ,   , , , :,::ii::i::
    :      iZMOMOMBBM2::::::::::,,,,     ,,,,,,:,,,::::i:irr:i:::,
    i   ,,:;u0MBMOG1L:::i::::::  ,,,::,   ,,, ::::::i:i:iirii:i:i:
    :    ,iuUuuXUkFu7i:iii:i:::, :,:,: ::::::::i:i:::::iirr7iiri::
    :     :rk@Yizero.i:::::, ,:ii:::::::i:::::i::,::::iirrriiiri::,
     :      5BMBBBBBBSr:,::rv2kuii:::iii::,:i:,, , ,,:,:i@petermu.,
          , :r50EZ8MBBBBGOBBBZP7::::i::,:::::,: :,:,::i;rrririiii::
              :jujYY7LS0ujJL7r::,::i::,::::::::::::::iirirrrrrrr:ii:
           ,:  :@kevensun.:,:,,,::::i:i:::::,,::::::iir;ii;7v77;ii;i,
           ,,,     ,,:,::::::i:iiiii:i::::,, ::::iiiir@xingjief.r;7:i,
        , , ,,,:,,::::::::iiiiiiiiii:,:,:::::::::iiir;ri7vL77rrirri::
         :,, , ::::::::i:::i:::i:i::,,,,,:,::i:i::用于区分不同模块比较方便
  */
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    throw UnimplementedError("getConversationList() has not been implemented");
  }

  Future<void> removeConversationListener({
    String? listenerUuid,
  }) async {
    throw UnimplementedError(
        'removeConversationListener() has not been implemented');
  }

  Future<void> removeFriendListener({
    String? listenerUuid,
  }) async {
    throw UnimplementedError('removeFriendListener() has not been implemented');
  }

  /// 通过会话ID获取指定会话列表
  ///
  Future<V2TimValueCallback<List<V2TimConversation>>>
      getConversationListByConversaionIds({
    required List<String> conversationIDList,
  }) async {
    throw UnimplementedError(
        "getConversationListByConversaionIds() has not been implemented");
  }

  Future<void> setConversationListener(
      {required V2TimConversationListener listener, String? listenerUuid}) {
    throw UnimplementedError(
        "setConversationListener() has not been implemented");
  }

  /// 获取指定会话
  ///
  /// 参数
  ///
  /// ```
  /// conversationID	会话唯一 ID，如果是 C2C 单聊，组成方式为 c2c_userID，如果是群聊，组成方式为 group_groupID
  ///
  /// ```
  ///
  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    required String conversationID,
  }) async {
    throw UnimplementedError("getConversation() has not been implemented");
  }

  /// 删除会话
  ///
  /// 请注意:
  ///
  /// ```
  /// 删除会话会在本地删除的同时，在服务器也会同步删除。
  /// 会话内的消息在本地删除的同时，在服务器也会同步删除。
  /// ```
  ///
  Future<V2TimCallback> deleteConversation({
    required String conversationID,
  }) async {
    throw UnimplementedError("deleteConversation() has not been implemented");
  }

  /// 设置会话草稿
  ///
  /// ```
  /// 只在本地保存，不会存储 Server，不能多端同步，程序卸载重装会失效。
  /// ```
  /// 参数
  ///
  /// ```
  /// draftText	草稿内容, 为 null 则表示取消草稿
  /// ```
  ///
  Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText,
  }) async {
    throw UnimplementedError('setConversationDraft() has not been implemented');
  }

  /// 会话置顶
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    throw UnimplementedError('pinConversation() has not been implemented');
  }

  /// 获取会话未读总数
  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    throw UnimplementedError(
        'getTotalUnreadMessageCount() has not implemented');
  }

  /*****************************-好友关系模块-***********************************/
  /*

                      :;J7, :,                        ::;7:
                      ,ivYi, ,                       ;LLLFS:
                      :iv7Yi                       :7ri;j5PL
                     ,:ivYLvr                    ,ivrrirrY2X,
                     :;r@Wwz.7r:                :ivu@kexianli.
                    :iL7::,:::iiirii:ii;::::,,irvF7rvvLujL7ur
                   ri::,:,::i:iiiiiii:i:irrv177JX7rYXqZEkvv17
                ;i:, , ::::iirrririi:i:::iiir2XXvii;L8OGJr71i
              :,, ,,:   ,::ir@mingyi.irii:i:::j1jri7ZBOS7ivv,
                 ,::,    ::rv77iiiriii:iii:i::,rvLq@huhao.Li
             ,,      ,, ,:ir7ir::,:::i;ir:::i:i::rSGGYri712:
           :::  ,v7r:: ::rrv77:, ,, ,:i7rrii:::::, ir7ri7Lri
          ,     2OBBOi,iiir;r::        ,irriiii::,, ,iv7Luur:
        ,,     i78MBBi,:,:::,:,  :7FSL: ,iriii:::i::,,:rLqXv::
        :      iuMMP: :,:::,:ii;2GY7OBB0viiii:i:iii:i:::iJqL;::
       ,     ::::i   ,,,,, ::LuBBu BBBBBErii:i:i:i:i:i:i:r77ii
      ,       :       , ,,:::rruBZ1MBBqi, :,,,:::,::::::iiriri:
     ,               ,,,,::::i:  @arqiao.       ,:,, ,:::ii;i7:
    :,       rjujLYLi   ,,:::::,:::::::::,,   ,:i,:,,,,,::i:iii
    ::      BBBBBBBBB0,    ,,::: , ,:::::: ,      ,,,, ,,:::::::
    i,  ,  ,8BMMBBBBBBi     ,,:,,     ,,, , ,   , , , :,::ii::i::
    :      iZMOMOMBBM2::::::::::,,,,     ,,,,,,:,,,::::i:irr:i:::,
    i   ,,:;u0MBMOG1L:::i::::::  ,,,::,   ,,, ::::::i:i:iirii:i:i:
    :    ,iuUuuXUkFu7i:iii:i:::, :,:,: ::::::::i:i:::::iirr7iiri::
    :     :rk@Yizero.i:::::, ,:ii:::::::i:::::i::,::::iirrriiiri::,
     :      5BMBBBBBBSr:,::rv2kuii:::iii::,:i:,, , ,,:,:i@petermu.,
          , :r50EZ8MBBBBGOBBBZP7::::i::,:::::,: :,:,::i;rrririiii::
              :jujYY7LS0ujJL7r::,::i::,::::::::::::::iirirrrrrrr:ii:
           ,:  :@kevensun.:,:,,,::::i:i:::::,,::::::iir;ii;7v77;ii;i,
           ,,,     ,,:,::::::i:iiiii:i::::,, ::::iiiir@xingjief.r;7:i,
        , , ,,,:,,::::::::iiiiiiiiii:,:,:::::::::iiir;ri7vL77rrirri::
         :,, , ::::::::i:::i:::i:i::,,,,,:,::i:i::用于区分不同模块比较方便
  */
  ///获取好友列表
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    throw UnimplementedError('getFriendList() has not been implemented');
  }

  /// 获取指定好友资料
  ///
  /// 参数
  ///
  /// ```
  /// userIDList	好友 userID 列表
  /// ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// ```
  ///

  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo({
    required List<String> userIDList,
  }) async {
    throw UnimplementedError('getFriendsInfo() has not been implemented');
  }

  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    String? remark,
    String? friendGroup,
    String? addWording,
    String? addSource,
    required int addType,
  }) async {
    throw UnimplementedError('addFriend() has not been implemented');
  }

  /// 设置指定好友资料
  ///
  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    throw UnimplementedError('setFriendInfo() has not been implemented');
  }

  ///设置关系链监听器
  ///
  Future<void> setFriendListener(
      {required V2TimFriendshipListener listener, String? listenerUuid}) async {
    throw UnimplementedError('setFriendListener() has not been implemented');
  }

  ///   删除好友
  ///
  /// 参数
  ///
  /// ```
  /// userIDList	要删除的好友 userID 列表
  /// ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// deleteType	删除类型
  /// ```
  ///
  /// ```
  /// V2TIMFriendInfo.V2TIM_FRIEND_TYPE_SINGLE：单向好友
  /// V2TIMFriendInfo.V2TIM_FRIEND_TYPE_BOTH：双向好友
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromFriendList({
    required List<String> userIDList,
    required int deleteType,
  }) async {
    throw UnimplementedError('deleteFromFriendList() has not been implemented');
  }

  /// 检查指定用户的好友关系
  ///
  /// 参数
  ///
  /// ```
  /// checkType	检查类型
  /// ```
  ///
  /// ```
  /// V2TIMFriendInfo.V2TIM_FRIEND_TYPE_SINGLE：单向好友
  /// V2TIMFriendInfo.V2TIM_FRIEND_TYPE_BOTH：双向好友
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({
    required List<String> userIDList,
    required int checkType,
  }) async {
    throw UnimplementedError("checkFriend() has not been implemented");
  }

  ///获取好友申请列表
  ///
  Future<V2TimValueCallback<V2TimFriendApplicationResult>>
      getFriendApplicationList() async {
    throw UnimplementedError(
        "getFriendApplicationList() has not been implemented");
  }

  /// 同意好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// responseType	建立单向/双向好友关系
  /// ```
  ///
  /// ```
  /// V2TIMFriendApplication.V2TIM_FRIEND_ACCEPT_AGREE：同意添加单向好友
  /// V2TIMFriendApplication.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD：同意并添加为双向好友
  /// ```
  ///
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      acceptFriendApplication({
    required int responseType,
    required int type,
    required String userID,
  }) async {
    throw UnimplementedError(
        "acceptFriendApplication() has not been implemented");
  }

  /// 拒绝好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// ```
  ///
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      refuseFriendApplication({
    required int type,
    required String userID,
  }) async {
    throw UnimplementedError(
        "refuseFriendApplication() has not been implemented");
  }

  /// 删除好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// ```
  ///
  Future<V2TimCallback> deleteFriendApplication({
    required int type,
    required String userID,
  }) async {
    throw UnimplementedError(
        "deleteFriendApplication() has not been implemented");
  }

  ///设置好友申请已读
  ///
  Future<V2TimCallback> setFriendApplicationRead() async {
    throw UnimplementedError(
        "setFriendApplicationRead() has not been implemented");
  }

  ///获取黑名单列表
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getBlackList() async {
    throw UnimplementedError("getBlackList() has not been implemented");
  }

  ///添加用户到黑名单
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList({
    required List<String> userIDList,
  }) async {
    throw UnimplementedError("addToBlackList() has not been implemented");
  }

  ///把用户从黑名单中删除
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    throw UnimplementedError("deleteFromBlackList() has not been implemented");
  }

  ///新建好友分组
  ///
  ///参数
  ///
  ///```
  /// groupName	分组名称
  /// userIDList	要添加到分组中的好友 userID 列表
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      createFriendGroup({
    required String groupName,
    List<String>? userIDList,
  }) async {
    throw UnimplementedError("createFriendGroup() has not been implemented");
  }

  /// 获取分组信息
  ///
  /// 参数
  ///
  /// ```
  /// groupNameList	要获取信息的好友分组名称列表,传入 null 获得所有分组信息
  /// ```
  Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({
    List<String>? groupNameList,
  }) async {
    throw UnimplementedError("getFriendGroups() has not been implemented");
  }

  ///删除好友分组
  ///
  Future<V2TimCallback> deleteFriendGroup({
    required List<String> groupNameList,
  }) async {
    throw UnimplementedError("deleteFriendGroups() has not been implemented");
  }

  /// 修改好友分组的名称
  ///
  /// 参数
  ///
  /// ```
  /// oldName	旧的分组名称
  /// newName	新的分组名称
  /// callback	回调(web无回调)
  /// ```
  ///
  Future<V2TimCallback> renameFriendGroup({
    required String oldName,
    required String newName,
  }) async {
    throw UnimplementedError("renameFriendGroup() has not been implemented");
  }

  ///添加好友到一个好友分组
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      addFriendsToFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    throw UnimplementedError(
        "addFriendsToFriendGroup() has not been implemented");
  }

  ///从好友分组中删除好友
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFriendsFromFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    throw UnimplementedError(
        "deleteFriendsFromFriendGroup() has not been implemented");
  }

  /// 搜索好友
  ///
  /// 接口返回本地存储的用户资料，可以根据 V2TIMFriendInfoResult 中的 relation 来判断是否为好友。
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> searchFriends({
    required V2TimFriendSearchParam searchParam,
  }) async {
    throw UnimplementedError("searchFriends() has not been implemented");
  }

  ///添加好友到一个好友分组
  ///
  /*****************************-群组关系模块-***********************************/
  /*

                      :;J7, :,                        ::;7:
                      ,ivYi, ,                       ;LLLFS:
                      :iv7Yi                       :7ri;j5PL
                     ,:ivYLvr                    ,ivrrirrY2X,
                     :;r@Wwz.7r:                :ivu@kexianli.
                    :iL7::,:::iiirii:ii;::::,,irvF7rvvLujL7ur
                   ri::,:,::i:iiiiiii:i:irrv177JX7rYXqZEkvv17
                ;i:, , ::::iirrririi:i:::iiir2XXvii;L8OGJr71i
              :,, ,,:   ,::ir@mingyi.irii:i:::j1jri7ZBOS7ivv,
                 ,::,    ::rv77iiiriii:iii:i::,rvLq@huhao.Li
             ,,      ,, ,:ir7ir::,:::i;ir:::i:i::rSGGYri712:
           :::  ,v7r:: ::rrv77:, ,, ,:i7rrii:::::, ir7ri7Lri
          ,     2OBBOi,iiir;r::        ,irriiii::,, ,iv7Luur:
        ,,     i78MBBi,:,:::,:,  :7FSL: ,iriii:::i::,,:rLqXv::
        :      iuMMP: :,:::,:ii;2GY7OBB0viiii:i:iii:i:::iJqL;::
       ,     ::::i   ,,,,, ::LuBBu BBBBBErii:i:i:i:i:i:i:r77ii
      ,       :       , ,,:::rruBZ1MBBqi, :,,,:::,::::::iiriri:
     ,               ,,,,::::i:  @arqiao.       ,:,, ,:::ii;i7:
    :,       rjujLYLi   ,,:::::,:::::::::,,   ,:i,:,,,,,::i:iii
    ::      BBBBBBBBB0,    ,,::: , ,:::::: ,      ,,,, ,,:::::::
    i,  ,  ,8BMMBBBBBBi     ,,:,,     ,,, , ,   , , , :,::ii::i::
    :      iZMOMOMBBM2::::::::::,,,,     ,,,,,,:,,,::::i:irr:i:::,
    i   ,,:;u0MBMOG1L:::i::::::  ,,,::,   ,,, ::::::i:i:iirii:i:i:
    :    ,iuUuuXUkFu7i:iii:i:::, :,:,: ::::::::i:i:::::iirr7iiri::
    :     :rk@Yizero.i:::::, ,:ii:::::::i:::::i::,::::iirrriiiri::,
     :      5BMBBBBBBSr:,::rv2kuii:::iii::,:i:,, , ,,:,:i@petermu.,
          , :r50EZ8MBBBBGOBBBZP7::::i::,:::::,: :,:,::i;rrririiii::
              :jujYY7LS0ujJL7r::,::i::,::::::::::::::iirirrrrrrr:ii:
           ,:  :@kevensun.:,:,,,::::i:i:::::,,::::::iir;ii;7v77;ii;i,
           ,,,     ,,:,::::::i:iiiii:i::::,, ::::iiiir@xingjief.r;7:i,
        , , ,,,:,,::::::::iiiiiiiiii:,:,:::::::::iiir;ri7vL77rrirri::
         :,, , ::::::::i:::i:::i:i::,,,,,:,::i:i::用于区分不同模块比较方便
  */

  /// 获取当前用户已经加入的群列表
  ///
  /// 注意
  ///
  /// ```
  /// 直播群(AVChatRoom) 不支持该 API。
  /// 该接口有频限检测，SDK 限制调用频率为1 秒 10 次，超过限制后会报 ERR_SDK_COMM_API_CALL_FREQUENCY_LIMIT （7008）错误
  /// ```

  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedGroupList() async {
    throw UnimplementedError('getJoinedGroupList() has not been implemented');
  }

  /// 拉取群资料
  ///
  /// 参数
  ///
  /// ```
  /// groupIDList	群 ID 列表
  ///
  Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    throw UnimplementedError('getGroupsInfo() has not been implemented');
  }

  Future<V2TimCallback> setGroupInfo({
    required V2TimGroupInfo info,
  }) async {
    throw UnimplementedError('setGroupInfo() has not been implemented');
  }

  /// 初始化群属性，会清空原有的群属性列表
  ///
  /// 注意
  ///
  /// attributes 的使用限制如下：
  ///
  /// ```
  /// 1、目前只支持 AVChatRoom
  /// 2、key 最多支持16个，长度限制为32字节
  /// 3、value 长度限制为4k
  /// 4、总的 attributes（包括 key 和 value）限制为16k
  /// 5、initGroupAttributes、setGroupAttributes、deleteGroupAttributes 接口合并计算， SDK 限制为5秒10次，超过后回调8511错误码；后台限制1秒5次，超过后返回10049错误码
  /// 6、getGroupAttributes 接口 SDK 限制5秒20次
  /// ```
  Future<V2TimCallback> initGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    throw UnimplementedError(" initGroupAttributeshas not been implemented");
  }

  ///设置群属性。已有该群属性则更新其 value 值，没有该群属性则添加该属性。
  ///
  Future<V2TimCallback> setGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    throw UnimplementedError('setGroupAttributes() has not been implemented');
  }

  ///删除指定群属性，keys 传 null 则清空所有群属性。
  ///
  Future<V2TimCallback> deleteGroupAttributes({
    required String groupID,
    required List<String> keys,
  }) async {
    throw UnimplementedError(
        'deleteGroupAttributes() has not been implemented');
  }

  ///获取指定群属性，keys 传 null 则获取所有群属性。
  ///
  Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({
    required String groupID,
    List<String>? keys,
  }) async {
    throw UnimplementedError('getGroupAttributes() has not been implemented');
  }

  ///获取指定群属性，keys 传 null 则获取所有群属性。
  ///
  Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({
    required String groupID,
  }) async {
    throw UnimplementedError(
        'getGroupOnlineMemberCount() has not been implemented');
  }

  /// 获取群成员列表
  ///
  /// 参数
  ///
  /// ```
  /// filter	指定群成员类型
  /// V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL：所有类型
  /// V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_OWNER：群主
  /// V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ADMIN：群管理员
  /// V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_COMMON：普通群成员
  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  /// ```
  /// 注意
  ///
  /// ```
  /// 直播群（AVChatRoom）的特殊限制：
  /// 不支持管理员角色的拉取，群成员个数最大只支持 31 个（新进来的成员会排前面），程序重启后，请重新加入群组，否则拉取群成员会报 10007 错误码。
  /// 群成员资料信息仅支持 userID | nickName | faceURL | role 字段。
  /// role 字段不支持管理员角色，如果您的业务逻辑依赖于管理员角色，可以使用群自定义字段 groupAttributes 管理该角色。
  /// ```
  /// web 端使用时，count 和 offset 为必传参数. filter 和 nextSeq 不生效
  /// count: 需要拉取的数量。最大值：100，避免回包过大导致请求失败。若传入超过100，则只拉取前100个。
  /// offset: 偏移量，默认从0开始拉取
  ///
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({
    required String groupID,
    required int filter,
    required String nextSeq,
    int count = 15,
    int offset = 0,
  }) async {
    throw UnimplementedError(
        'getGroupOnlineMemberList() has not been implemented');
  }

  ///获取指定的群成员资料
  ///
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>>
      getGroupMembersInfo({
    required String groupID,
    required List<String> memberList,
  }) async {
    throw UnimplementedError('getGroupMembersInfo() has not been implemented');
  }

  ///修改指定的群成员资料
  ///
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    throw UnimplementedError('setGroupMemberInfo() has not been implemented');
  }

  ///禁言（只有管理员或群主能够调用）
  ///
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    throw UnimplementedError('muteGroupMember() has not been implemented');
  }

  /// 邀请他人入群
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：群里的任何人都可以邀请其他人进群。
  /// 会议群（Meeting）和公开群（Public）：只有通过rest api 使用 App 管理员身份才可以邀请其他人进群。
  /// 直播群（AVChatRoom）：不支持此功能。
  /// ```
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    throw UnimplementedError("InviteUserToGroup() has not been implemented");
  }

  /// 踢人
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：只有群主或 APP 管理员可以踢人。
  /// 公开群（Public）、会议群（Meeting）：群主、管理员和 APP 管理员可以踢人
  /// 直播群（AVChatRoom）：只支持禁言（muteGroupMember），不支持踢人。
  /// ```
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    String? reason,
  }) async {
    throw UnimplementedError("InviteUserToGroup() has not been implemented");
  }

  /// 切换群成员的角色。
  ///
  /// 注意
  ///
  /// ```
  /// 公开群（Public）和会议群（Meeting）：只有群主才能对群成员进行普通成员和管理员之间的角色切换。
  /// 其他群不支持设置群成员角色。
  /// 转让群组请调用 transferGroupOwner 接口。
  /// ```
  ///
  /// 参数
  ///
  /// ```
  /// role	切换的角色支持： V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_MEMBER：普通群成员 V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_ADMIN：管理员
  /// ```
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required int role,
  }) async {
    throw UnimplementedError("setGroupMemberRole() has not been implemented");
  }

  /// 转让群主
  ///
  /// 注意
  ///
  /// ```
  /// 普通类型的群（Work、Public、Meeting）：只有群主才有权限进行群转让操作。
  /// 直播群（AVChatRoom）：不支持转让群主。
  /// ```
  Future<V2TimCallback> transferGroupOwner({
    required String groupID,
    required String userID,
  }) async {
    throw UnimplementedError("transferGroupOwner() has not been implemented");
  }

  ///获取加群的申请列表
  ///
  ///web 不支持
  ///
  Future<V2TimValueCallback<V2TimGroupApplicationResult>>
      getGroupApplicationList() async {
    throw UnimplementedError(
        "getGroupApplicationList() has not been implemented");
  }

  ///同意某一条加群申请
  ///
  ///
  //web 端使用时必须传入webMessageInstance 字段。 对应【群系统通知】的消息实例
  ///
  Future<V2TimCallback> acceptGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    int? type,
    String? webMessageInstance,
  }) async {
    throw UnimplementedError(
        "acceptGroupApplication() has not been implemented");
  }

  ///拒绝某一条加群申请
  ///
  ///web 端使用时必须传入webMessageInstance 字段。 对应【群系统通知】的消息实例
  ///
  Future<V2TimCallback> refuseGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    required int addTime,
    required int type,
    String? webMessageInstance,
  }) async {
    throw UnimplementedError(
        "acceptGroupApplication() has not been implemented");
  }

  ///标记申请列表为已读
  ///
  /// web 不支持
  ///
  Future<V2TimCallback> setGroupApplicationRead() async {
    throw UnimplementedError(
        "setGroupApplicationRead() has not been implemented");
  }

  /// 搜索群资料
  ///
  /// web 不支持关键字搜索搜索, 请使用searchGroupByID
  ///
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    throw UnimplementedError("searchGroups() has not been implemented");
  }

  /// 搜索群成员
  ///
  /// web 不支持搜索
  ///
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({
    required V2TimGroupMemberSearchParam param,
  }) async {
    throw UnimplementedError("searchGroupMembers() has not been implemented");
  }

  /// 通过 groupID 搜索群组
  /// 注意： 好友工作群不能被搜索
  /// 仅 web 支持该搜索方式
  ///
  Future<V2TimValueCallback<V2TimGroupInfo>> searchGroupByID({
    required String groupID,
  }) async {
    throw UnimplementedError("searchGroupByID() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage(
      {required String text}) async {
    throw UnimplementedError("createTextMessage() has not been implemented");
  }

  ///  创建定向群消息
  /// 如果您需要在群内给指定群成员列表发消息，可以创建一条定向群消息，定向群消息只有指定群成员才能收到。
  /// 原始消息对象不支持群 @ 消息。
  /// 社群（Community）和直播群（AVChatRoom）不支持发送定向群消息。
  /// 定向群消息默认不计入群会话的未读计数。
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>>
      createTargetedGroupMessage(
          {required String id, required List<String> receiverList}) async {
    throw UnimplementedError("createTextMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage(
      {required String imagePath,
      Uint8List? fileContent, // web 必填
      String? fileName //web必填写
      }) async {
    throw UnimplementedError("createImageMessage() has not been implemented");
  }

  /// 3.6.0 新接口统一发送消息实例
  Future<V2TimValueCallback<V2TimMessage>> sendMessage(
      {required String id,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool needReadReceipt = false,
      bool isExcludedFromUnreadCount = false,
      bool isExcludedFromLastMessage = false,
      Map<String, dynamic>? offlinePushInfo,
      String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
      String? localCustomData // 本地自定义消息字段
      }) async {
    throw UnimplementedError("sendMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage({
    required String data,
    String desc = "",
    String extension = "",
  }) async {
    throw UnimplementedError("createCustomMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createSoundMessage({
    required String soundPath,
    required int duration,
  }) async {
    throw UnimplementedError("createSoundMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage(
      {required String videoFilePath,
      required String type,
      required int duration,
      required String snapshotPath,
      Uint8List? fileContent,
      String? fileName}) async {
    throw UnimplementedError("createSoundMessage() has not been implemented");
  }

  /// 发送文件消息
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage(
      {required String filePath,
      required String fileName,
      Uint8List? fileContent}) async {
    throw UnimplementedError("createFileMessage() has not been implemented");
  }

  // 创建at消息
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    throw UnimplementedError("createTextAtMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    throw UnimplementedError(
        "createLocationMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({
    required int index,
    required String data,
  }) async {
    throw UnimplementedError("createFaceMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      List<String>? webMessageInstanceList}) async {
    throw UnimplementedError("createMergerMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage(
      {required String msgID, String? webMessageInstance}) async {
    throw UnimplementedError("createForwardMessage() has not been implemented");
  }

  ///发送高级文本消息
  Future<V2TimValueCallback<V2TimMessage>> sendTextMessage({
    required String text,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    throw UnimplementedError("sendTextMessage() has not been implemented");
  }

  ///发送自定义消息
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendCustomMessage({
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    String desc = "",
    String extension = "",
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    throw UnimplementedError("send() has not been implemented");
  }

  ///发送图片消息
  ///
  ///web 端发送图片消息时需要传入fileName、fileContent 字段
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendImageMessage(
      {required String imagePath,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      String? fileName,
      Uint8List? fileContent}) async {
    throw UnimplementedError("sendImageMessage() has not been implemented");
  }

  ///发送视频消息
  ///
  ///web 端发送视频消息时需要传入fileName, fileContent字段
  ///不支持 snapshotPath、duration、type
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendVideoMessage({
    required String videoFilePath,
    required String receiver,
    required String type,
    required String snapshotPath,
    required int duration,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
    String? fileName,
    Uint8List? fileContent,
  }) async {
    throw UnimplementedError("sendVideoMessage() has not been implemented");
  }

  ///发送文件
  /// web 端 fileName、fileContent 为必传字段
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendFileMessage(
      {required String filePath,
      required String fileName,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      Uint8List? fileContent}) async {
    throw UnimplementedError("sendImageMessage() has not been implemented");
  }

  /// 发送语音消息
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage({
    required String soundPath,
    required String receiver,
    required String groupID,
    required int duration,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    throw UnimplementedError("sendSoundMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMessage>> sendTextAtMessage({
    required String text,
    required List<String> atUserList,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    throw UnimplementedError("sendTextAtMessage () has not been implemented");
  }

  /// 发送地理位置消息
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    throw UnimplementedError("sendLocationMessage () has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMessage>> sendFaceMessage({
    required int index,
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    throw UnimplementedError("sendFaceMessage () has not been implemented");
  }

  /// 合并消息
  ///
  /// 我们在收到一条合并消息的时候，通常会在聊天界面这样显示：
  ///
  /// |vinson 和 lynx 的聊天记录 | – title （标题）
  ///
  /// |vinson：新版本 SDK 计划什么时候上线呢？ | – abstract1 （摘要信息1）
  ///
  /// |lynx：计划下周一，具体时间要看下这两天的系统测试情况.. | – abstract2 （摘要信息2）
  ///
  /// |vinson：好的. | – abstract3 （摘要信息3）
  ///
  /// 聊天界面通常只会展示合并消息的标题和摘要信息，完整的转发消息列表，需要用户主动点击转发消息 UI 后再获取。
  ///
  /// 多条被转发的消息可以被创建成一条合并消息 V2TIMMessage，然后调用 sendMessage 接口发送，实现步骤如下：
  ///
  /// 1. 调用 createMergerMessage 创建一条合并消息 V2TIMMessage。
  ///
  /// 2. 调用 sendMessage 发送转发消息 V2TIMMessage。
  ///
  /// 收到合并消息解析步骤：
  ///
  /// 1. 通过 V2TIMMessage 获取 mergerElem。
  ///
  /// 2. 通过 mergerElem 获取 title 和 abstractList UI 展示。
  ///
  /// 3. 当用户点击摘要信息 UI 的时候，调用 downloadMessageList 接口获取转发消息列表。
  ///
  ///
  /// 注意
  /// web 端使用时必须传入webMessageInstanceList 字段。 在web端返回的消息实例会包含该字段
  ///
  Future<V2TimValueCallback<V2TimMessage>> sendMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      List<String>? webMessageInstanceList}) async {
    throw UnimplementedError("sendMergerMessage () has not been implemented");
  }

  /// 设置消息自定义数据（本地保存，不会发送到对端，程序卸载重装后失效）
  ///
  /// 注意： web不支持该接口
  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    throw UnimplementedError("setLocalCustomData has not been implemented");
  }

  /// 设置消息自定义数据，可以用来标记语音、视频消息是否已经播放（本地保存，不会发送到对端，程序卸载重装后失效）
  ///
  ///web 不支持
  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    throw UnimplementedError("setLocalCustomInt has not been implemented");
  }

  /// 设置云端自定义数据（云端保存，会发送到对端，程序卸载重装后还能拉取到）
  ///
  ///web 不支持
  Future<V2TimCallback> setCloudCustomData({
    required String data,
    required String msgID,
  }) async {
    throw UnimplementedError("setCloudCustom() has not been implemented");
  }

  /// 获取单聊历史消息
  ///
  /// 参数
  ///
  /// ```
  /// count	拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
  /// lastMsg	获取消息的起始消息，如果传 null，起始消息为会话的最新消息
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 如果 SDK 检测到没有网络，默认会直接返回本地数据
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    throw UnimplementedError(
        "getC2CHistoryMessageList() has not been implemented");
  }

  /// 获取群组历史消息
  ///
  /// 参数
  ///
  /// ```
  /// count	拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
  /// lastMsg	获取消息的起始消息，如果传 null，起始消息为会话的最新消息
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 如果 SDK 检测到没有网络，默认会直接返回本地数据
  /// 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
  /// ```
  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    throw UnimplementedError("getGroupHistoryMessageList");
  }

  /// 获取历史消息高级接口(没有处理Native返回数据)
  ///
  /// 参数
  /// option	拉取消息选项设置，可以设置从云端、本地拉取更老或更新的消息
  ///
  /// 请注意：
  /// 如果设置为拉取云端消息，当 SDK 检测到没有网络，默认会直接返回本地数据
  /// 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
  ///
  /// 注意： web不支持该接口
  ///
  Future<LinkedHashMap<dynamic, dynamic>> getHistoryMessageListWithoutFormat({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
  }) async {
    throw UnimplementedError(
        "getHistoryMessageListWithoutFormat() is not implemented");
  }

  /// 撤回消息
  ///
  /// 注意
  ///
  /// ```
  /// 撤回消息的时间限制默认 2 minutes，超过 2 minutes 的消息不能撤回，您也可以在 控制台（功能配置 -> 登录与消息 -> 消息撤回设置）自定义撤回时间限制。
  /// 仅支持单聊和群组中发送的普通消息，无法撤销 onlineUserOnly 为 true 即仅在线用户才能收到的消息，也无法撤销直播群（AVChatRoom）中的消息。
  /// 如果发送方撤回消息，已经收到消息的一方会收到 V2TIMAdvancedMsgListener -> onRecvMessageRevoked 回调。
  ///
  ///
  /// web 端掉用 webMessageInstatnce 为必传
  /// ```
  ///
  Future<V2TimCallback> revokeMessage(
      {required String msgID, Object? webMessageInstatnce}) async {
    throw UnimplementedError("revokeMessage() has not been implemented");
  }

  ///设置单聊消息已读
  ///
  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    throw UnimplementedError("markC2CMessageAsRead() has not been implemented");
  }

  /// 获取历史消息高级接口
  ///
  /// 参数
  /// option	拉取消息选项设置，可以设置从云端、本地拉取更老或更新的消息
  ///
  /// 请注意：
  /// 如果设置为拉取云端消息，当 SDK 检测到没有网络，默认会直接返回本地数据
  /// 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
  ///
  ///web 端使用该接口，消息都是从远端拉取，不支持lastMsgSeq
  ///
  ///
  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
  }) async {
    throw UnimplementedError(
        "getHistoryMessageList() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMessage>> sendForwardMessage(
      {required String msgID,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      String? webMessageInstance}) async {
    throw UnimplementedError("SendForwardMessage() has not been implemented");
  }

  Future<V2TimValueCallback<V2TimMessage>> reSendMessage(
      {required String msgID,
      bool onlineUserOnly = false,
      Object? webMessageInstatnce}) async {
    throw UnimplementedError("SendForwardMessage() has not been implemented");
  }

  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required int opt,
  }) async {
    throw UnimplementedError("SendForwardMessage() has not been implemented");
  }

  ///查询针对某个用户的 C2C 消息接收选项
  ///
  ///注意： web不支持该接口
  ///
  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>>
      getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    throw UnimplementedError(
        "getC2CReceiveMessageOpt () has not been implemented");
  }

  /// 修改群消息接收选项
  ///
  /// 参数
  /// opt	三种类型的消息接收选项： V2TIMMessage.V2TIM_GROUP_RECEIVE_MESSAGE：在线正常接收消息，离线时会有厂商的离线推送通知 V
  /// 2TIMMessage.V2TIM_GROUP_NOT_RECEIVE_MESSAGE：不会接收到群消息
  /// V2TIMMessage.V2TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE：在线正常接收消息，离线不会有推送通知
  ///
  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required int opt,
  }) async {
    throw UnimplementedError("setGroupReceive() has not been implemented");
  }

  /// 设置群组消息已读
  ///
  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    throw UnimplementedError(
        "markGroupMessageAsRead() has not been implemented");
  }

  /// 删除本地消息
  ///
  /// 注意
  ///
  /// ```
  /// 消息只能本地删除，消息删除后，SDK 会在本地把这条消息标记为已删除状态，getHistoryMessage 不能再拉取到， 但是如果程序卸载重装，本地会失去对这条消息的删除标记，getHistoryMessage 还能再拉取到该条消息。
  /// ```
  /// 注意： web不支持该接口
  ///
  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    throw UnimplementedError(
        "deleteMessageFromLocalStorage () has not been implemented");
  }

  /// 删除本地及漫游消息
  ///
  /// 注意
  ///
  /// ```
  ///该接口会删除本地历史的同时也会把漫游消息即保存在服务器上的消息也删除，卸载重装后无法再拉取到。需要注意的是：
  ///   一次最多只能删除 30 条消息
  ///   要删除的消息必须属于同一会话
  ///   一秒钟最多只能调用一次该接口
  ///   如果该账号在其他设备上拉取过这些消息，那么调用该接口删除后，这些消息仍然会保存在那些设备上，即删除消息不支持多端同步。
  /// ```
  ///
  Future<V2TimCallback> deleteMessages(
      {required List<String> msgIDs,
      List<dynamic>? webMessageInstanceList}) async {
    throw UnimplementedError("deleteMessages () has not been implemented");
  }

  ///向群组消息列表中添加一条消息
  ///
  ///该接口主要用于满足向群组聊天会话中插入一些提示性消息的需求，比如“您已经退出该群”，这类消息有展示 在聊天消息区的需求，但并没有发送给其他人的必要。 所以 insertGroupMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
  ///
  ///返回[V2TimMessage]
  ///
  ///通过该接口 save 的消息只存本地，程序卸载后会丢失。
  ///
  ///注意： web不支持该接口
  ///
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    throw UnimplementedError(
        "insertGroupMessageToLocalStorage () has not been implemented");
  }

  ///向C2C消息列表中添加一条消息
  ///
  ///该接口主要用于满足向C2C聊天会话中插入一些提示性消息的需求，比如“您已成功发送消息”，这类消息有展示 在聊天消息区的需求，但并没有发送给其他人的必要。 所以 insertC2CMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
  ///
  ///返回[V2TimMessage]
  ///
  ///通过该接口 save 的消息只存本地，程序卸载后会丢失。
  ///
  ///注意： web不支持该接口
  ///
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    throw UnimplementedError(
        "insertC2CMessageToLocalStorage () has not been implemented");
  }

  /// 清空单聊本地及云端的消息（不删除会话）
  ///
  /// 5.4.666 及以上版本支持
  ///
  /// 注意
  /// 请注意：
  /// 会话内的消息在本地删除的同时，在服务器也会同步删除。
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    throw UnimplementedError(
        "clearC2CHistoryMessage () has not been implemented");
  }

  /// 清空群聊本地及云端的消息（不删除会话）
  ///
  /// 5.4.666 及以上版本支持
  ///
  /// 注意
  /// 请注意：
  /// 会话内的消息在本地删除的同时，在服务器也会同步删除。
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    throw UnimplementedError(
        "clearGroupHistoryMessage() has not been implemented");
  }

  /// 搜索本地消息
  ///
  /// 注意： web不支持该接口
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    throw UnimplementedError("searchLocalMessages() has not been implemented");
  }

  Future<V2TimCallback> markAllMessageAsRead() async {
    throw UnimplementedError("markAllMessageAsRead() has not been implemented");
  }

  /// 根据 messageID 查询指定会话中的本地消息
  ///
  /// 注意： web不支持该接口
  ///
  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    throw UnimplementedError("findMessages() is not implemented");
  }

  /// 设置群组监听器
  ///
  /// 在web端时，不支持onQuitFromGroup回调
  ///
  Future<void> setGroupListener(
      {required V2TimGroupListener listener, String? listenerUuid}) async {
    throw UnimplementedError('setGroupListener() has not been implemented.');
  }

  /// 添加高级消息的事件监听器
  ///
  Future<void> addAdvancedMsgListener({
    required V2TimAdvancedMsgListener listener,
    String? listenerUuid,
  }) async {
    throw UnimplementedError(
        'addAdvancedMsgListener() has not been implemented.');
  }

  Future<void> addConversationListener({
    required V2TimConversationListener listener,
    String? listenerUuid,
  }) async {
    throw UnimplementedError(
        'addConversationListener() has not been implemented.');
  }

  Future<void> addGroupListener({
    required V2TimGroupListener listener,
    String? listenerUuid,
  }) async {
    throw UnimplementedError('addGroupListener() has not been implemented.');
  }

  Future<void> removeGroupListener({
    String? listenerUuid,
  }) async {
    throw UnimplementedError('removeGroupListener() has not been implemented.');
  }

  Future<void> addFriendListener({
    required V2TimFriendshipListener listener,
    String? listenerUuid,
  }) async {
    throw UnimplementedError('addFriendListener() has not been implemented.');
  }

  /// 移除高级消息监听器
  ///
  Future<void> removeAdvancedMsgListener({String? listenerUuid}) async {
    throw UnimplementedError(
        'removeAdvancedMsgListener() has not been implemented.');
  }

  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    throw UnimplementedError(
        'sendMessageReadReceipts() has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    throw UnimplementedError(
        'getMessageReadReceipts() has not been implemented.');
  }

  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>>
      getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  }) async {
    throw UnimplementedError(
        'getGroupMessageReadMemberList() has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimGroupInfo>>>
      getJoinedCommunityList() async {
    throw UnimplementedError(
        'getJoinedCommunityList has not been implemented.');
  }

  Future<V2TimValueCallback<String>> createTopicInCommunity({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    throw UnimplementedError(
        'createTopicInCommunity has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      deleteTopicFromCommunity({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    throw UnimplementedError(
        'deleteTopicFromCommunity has not been implemented.');
  }

  Future<V2TimCallback> setTopicInfo({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    throw UnimplementedError('setTopicInfo has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimTopicInfoResult>>> getTopicInfoList({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    throw UnimplementedError('getTopicInfoList has not been implemented.');
  }

  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    throw UnimplementedError('modifyMessage has not been implemented.');
  }

  /// 能力位检测
  ///
  ///
  Future<V2TimValueCallback<int>> checkAbility() {
    throw UnimplementedError('checkAbility has not been implemented.');
  }

  Future<V2TimValueCallback<V2TimMessage>> appendMessage({
    required String createMessageBaseId,
    required String createMessageAppendId,
  }) async {
    throw UnimplementedError('appendMessage has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({
    required List<String> userIDList,
  }) {
    throw UnimplementedError('getUserStatus has not been implemented.');
  }

  Future<V2TimCallback> subscribeUserStatus({
    required List<String> userIDList,
  }) {
    throw UnimplementedError('subscribeUserStatus has not been implemented.');
  }

  Future<V2TimCallback> unsubscribeUserStatus({
    required List<String> userIDList,
  }) {
    throw UnimplementedError('unsubscribeUserStatus has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      setConversationCustomData({
    required String customData,
    required List<String> conversationIDList,
  }) async {
    throw UnimplementedError(
        'setConversationCustomData has not been implemented.');
  }

  Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationListByFilter({
    required V2TimConversationListFilter filter,
  }) async {
    throw UnimplementedError(
        'getConversationListByFilter has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      markConversation({
    required int markType,
    required bool enableMark,
    required List<String> conversationIDList,
  }) async {
    throw UnimplementedError('markConversation has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      createConversationGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    throw UnimplementedError(
        'createConversationGroup has not been implemented.');
  }

  Future<V2TimValueCallback<List<String>>> getConversationGroupList() async {
    throw UnimplementedError(
        'getConversationGroupList has not been implemented.');
  }

  Future<V2TimCallback> deleteConversationGroup({
    required String groupName,
  }) async {
    throw UnimplementedError(
        'deleteConversationGroup has not been implemented.');
  }

  Future<V2TimCallback> renameConversationGroup({
    required String oldName,
    required String newName,
  }) async {
    throw UnimplementedError(
        'renameConversationGroup has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      addConversationsToGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    throw UnimplementedError(
        'addConversationsToGroup has not been implemented.');
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationsFromGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    throw UnimplementedError(
        'deleteConversationsFromGroup has not been implemented.');
  }

  Future<V2TimCallback> setSelfStatus({
    required String status,
  }) async {
    throw UnimplementedError('setSelfStatus has not been implemented.');
  }
}
