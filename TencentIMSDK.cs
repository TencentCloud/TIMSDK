using com.tencent.imsdk.unity.native;
using com.tencent.imsdk.unity.utils;
using com.tencent.imsdk.unity.callback;
using com.tencent.imsdk.unity.enums;
using com.tencent.imsdk.unity.types;
using Newtonsoft.Json;
using UnityEngine;
using AOT;
using System.Text;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;


namespace com.tencent.imsdk.unity
{
    public class TencentIMSDK
    {
        private static SynchronizationContext mainSyncContext = SynchronizationContext.Current;

        private static Dictionary<string, object> ValuecallbackStore = new Dictionary<string, object>();

        private static RecvNewMsgCallback RecvNewMsgCallbackStore;

        private static MsgReadedReceiptCallback MsgReadedReceiptCallbackStore;
        private static MsgRevokeCallback MsgRevokeCallbackStore;
        private static MsgElemUploadProgressCallback MsgElemUploadProgressCallbackStore;
        private static GroupTipsEventCallback GroupTipsEventCallbackStore;

        private static GroupAttributeChangedCallback GroupAttributeChangedCallbackStore;

        private static ConvEventCallback ConvEventCallbackStore;

        private static ConvTotalUnreadMessageCountChangedCallback ConvTotalUnreadMessageCountChangedCallbackStore;
        private static NetworkStatusListenerCallback NetworkStatusListenerCallbackStore;
        private static KickedOfflineCallback KickedOfflineCallbackStore;
        private static UserSigExpiredCallback UserSigExpiredCallbackStore;
        private static OnAddFriendCallback OnAddFriendCallbackStore;
        private static OnDeleteFriendCallback OnDeleteFriendCallbackStore;
        private static UpdateFriendProfileCallback UpdateFriendProfileCallbackStore;
        private static FriendAddRequestCallback FriendAddRequestCallbackStore;
        private static FriendApplicationListDeletedCallback FriendApplicationListDeletedCallbackStore;
        private static FriendApplicationListReadCallback FriendApplicationListReadCallbackStore;
        private static FriendBlackListAddedCallback FriendBlackListAddedCallbackStore;
        private static FriendBlackListDeletedCallback FriendBlackListDeletedCallbackStore;
        private static LogCallback LogCallbackStore;
        private static MsgUpdateCallback MsgUpdateCallbackStore;



        [MonoPInvokeCallback(typeof(ValueCallback<ReponseInfo>))]
        public static void CallExperimentalAPICallback(int code, string desc, ReponseInfo data, string user_data) { }

        /// <summary>
        /// 初始化IM SDK
        /// </summary>
        /// <param name="sdk_app_id">sdk_app_id，在腾讯云即时通信 IM控制台创建应用后获得</param>
        /// <param name="json_sdk_config"><see cref="SdkConfig"/></param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult Init(long sdk_app_id, SdkConfig json_sdk_config)
        {
            ExperimentalAPIReqeustParam param = new ExperimentalAPIReqeustParam();

            param.request_internal_operation = TIMInternalOperation.internal_operation_set_ui_platform.ToString();

            param.request_set_ui_platform_param = "unity";

            TIMResult res = CallExperimentalAPI(param, CallExperimentalAPICallback);

            string configString = Utils.ToJson(json_sdk_config);

            Utils.Log(configString);

            int timSucc = IMNativeSDK.TIMInit(sdk_app_id, Utils.string2intptr(configString));

            return (TIMResult)timSucc;
        }
        /// <summary>
        /// 反初始化IM SDK
        /// </summary>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult Uninit()
        {
            RemoveRecvNewMsgCallback();

            SetConvEventCallback(null);

            SetConvTotalUnreadMessageCountChangedCallback(null);

            SetFriendAddRequestCallback(null);

            SetFriendApplicationListDeletedCallback(null);

            SetFriendApplicationListReadCallback(null);

            SetFriendBlackListAddedCallback(null);

            SetFriendBlackListDeletedCallback(null);

            SetGroupAttributeChangedCallback(null);

            SetGroupTipsEventCallback(null);

            SetKickedOfflineCallback(null);

            SetLogCallback(null);

            SetMsgElemUploadProgressCallback(null);

            SetMsgReadedReceiptCallback(null);

            SetMsgRevokeCallback(null);

            SetMsgUpdateCallback(null);

            SetNetworkStatusListenerCallback(null);

            SetOnAddFriendCallback(null);

            SetOnDeleteFriendCallback(null);

            SetUpdateFriendProfileCallback(null);


            SetUserSigExpiredCallback(null);


            int timSucc = IMNativeSDK.TIMUninit();

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 登录
        /// </summary>
        /// <param name="user_id">用户ID</param>
        /// <param name="user_sig">通过sdk_app_id与secret生成，可参考 https://cloud.tencent.com/document/product/269/32688</param>
        /// <param name="callback">回调 <see cref="ValueCallback"/> </param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult Login(string user_id, string user_sig, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMLogin(Utils.string2intptr(user_id), Utils.string2intptr(user_sig), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult Login(string user_id, string user_sig, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMLogin(Utils.string2intptr(user_id), Utils.string2intptr(user_sig), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 初始化IM SDK底层库版本
        /// </summary>
        /// <returns>string version</returns>
        public static string GetSDKVersion()
        {


            IntPtr version = IMNativeSDK.TIMGetSDKVersion();

            return Utils.intptr2string(version);
        }

        /// <summary>
        /// 设置全局配置
        /// </summary>
        /// <param name="config">配置 SetConfig</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult SetConfig(SetConfig config, ValueCallback<types.SetConfig> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMSetConfig(Utils.string2intptr(Utils.ToJson(config)), ValueCallbackInstance<types.SetConfig>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult SetConfig(SetConfig config, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMSetConfig(Utils.string2intptr(Utils.ToJson(config)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取服务端时间（秒）
        /// </summary>
        /// <returns>服务器时间</returns>
        public static long GetServerTime()
        {
            return IMNativeSDK.TIMGetServerTime();
        }

        /// <summary>
        /// 退出登录
        /// </summary>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult Logout(ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMLogout(ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult Logout(ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMLogout(ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 获取当前登录状态
        /// </summary>
        /// <returns>TIMLoginStatus</returns>
        public static TIMLoginStatus GetLoginStatus()
        {

            int timSucc = IMNativeSDK.TIMGetLoginStatus();

            return (TIMLoginStatus)timSucc;
        }

        /// <summary>
        /// 获取当前登录用户ID
        /// </summary>
        /// <param name="user_id">用户与接收user_id的StringBuilder</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GetLoginUserID(StringBuilder user_id)
        {
            int timSucc = IMNativeSDK.TIMGetLoginUserID(user_id);
            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 获取会话列表
        /// </summary>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ConvGetConvList(ValueCallback<List<ConvInfo>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvGetConvList(ValueCallbackInstance<List<ConvInfo>>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult ConvGetConvList(ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvGetConvList(ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 删除会话
        /// </summary>
        /// <param name="conv_id">会话ID，c2c会话为user_id，群会话为group_id</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ConvDelete(string conv_id, TIMConvType conv_type, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvDelete(Utils.string2intptr(conv_id), (int)conv_type, ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult ConvDelete(string conv_id, TIMConvType conv_type, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvDelete(Utils.string2intptr(conv_id), (int)conv_type, ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 获取会话信息
        /// </summary>
        /// <param name="conv_list_param">获取会话列表参数 ConvParam列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ConvGetConvInfo(List<ConvParam> conv_list_param, ValueCallback<List<ConvInfo>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvGetConvInfo(Utils.string2intptr(Utils.ToJson(conv_list_param)), ValueCallbackInstance<List<ConvInfo>>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult ConvGetConvInfo(List<ConvParam> conv_list_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvGetConvInfo(Utils.string2intptr(Utils.ToJson(conv_list_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 设置会话草稿
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="param">DraftParam</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ConvSetDraft(string conv_id, TIMConvType conv_type, DraftParam param)
        {




            int timSucc = IMNativeSDK.TIMConvSetDraft(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(param)));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 取消会话草稿
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ConvCancelDraft(string conv_id, TIMConvType conv_type)
        {

            int timSucc = IMNativeSDK.TIMConvCancelDraft(conv_id, (int)conv_type);

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 会话置顶
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="is_pinned">是否置顶标记</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ConvPinConversation(string conv_id, TIMConvType conv_type, bool is_pinned, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvPinConversation(conv_id, (int)conv_type, is_pinned, ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult ConvPinConversation(string conv_id, TIMConvType conv_type, bool is_pinned, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvPinConversation(conv_id, (int)conv_type, is_pinned, ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 获取全部会话未读数
        /// </summary>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ConvGetTotalUnreadMessageCount(ValueCallback<GetTotalUnreadNumberResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvGetTotalUnreadMessageCount(ValueCallbackInstance<GetTotalUnreadNumberResult>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult ConvGetTotalUnreadMessageCount(ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMConvGetTotalUnreadMessageCount(ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 发送消息
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message">消息体 Message</param>
        /// <param name="message_id">承接消息ID的StringBuilder</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgSendMessage(string conv_id, TIMConvType conv_type, Message message, StringBuilder message_id, ValueCallback<Message> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSendMessage(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message)), message_id, ValueCallbackInstance<Message>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgSendMessage(string conv_id, TIMConvType conv_type, Message message, StringBuilder message_id, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSendMessage(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message)), message_id, ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 取消消息发送
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message_id">消息ID</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgCancelSend(string conv_id, TIMConvType conv_type, string message_id, ValueCallback<Message> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgCancelSend(conv_id, (int)conv_type, Utils.string2intptr(message_id), ValueCallbackInstance<Message>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgCancelSend(string conv_id, TIMConvType conv_type, string message_id, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgCancelSend(conv_id, (int)conv_type, Utils.string2intptr(message_id), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 从本地查找消息
        /// </summary>
        /// <param name="message_id_array">查找消息的id列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgFindMessages(List<string> message_id_array, ValueCallback<List<Message>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgFindMessages(Utils.string2intptr(Utils.ToJson(message_id_array)), ValueCallbackInstance<List<Message>>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgFindMessages(List<string> message_id_array, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgFindMessages(Utils.string2intptr(Utils.ToJson(message_id_array)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 消息已读上报
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message">消息体 Message</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgReportReaded(string conv_id, TIMConvType conv_type, Message message, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgReportReaded(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgReportReaded(string conv_id, TIMConvType conv_type, Message message, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgReportReaded(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 标记所有消息为已读
        /// </summary>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgMarkAllMessageAsRead(ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgMarkAllMessageAsRead(ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgMarkAllMessageAsRead(ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgMarkAllMessageAsRead(ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 消息撤回
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message">消息体 Message</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgRevoke(string conv_id, TIMConvType conv_type, Message message, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgRevoke(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgRevoke(string conv_id, TIMConvType conv_type, Message message, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgRevoke(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 通过消息定位符查找消息
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message_locator">消息定位符 MsgLocator</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgFindByMsgLocatorList(string conv_id, TIMConvType conv_type, MsgLocator message_locator, ValueCallback<List<Message>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgFindByMsgLocatorList(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message_locator)), ValueCallbackInstance<List<Message>>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgFindByMsgLocatorList(string conv_id, TIMConvType conv_type, MsgLocator message_locator, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgFindByMsgLocatorList(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message_locator)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 导入消息
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message_list">消息列表 Message列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgImportMsgList(string conv_id, TIMConvType conv_type, List<Message> message_list, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgImportMsgList(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message_list)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgImportMsgList(string conv_id, TIMConvType conv_type, List<Message> message_list, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgImportMsgList(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message_list)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 保存消息
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message">消息体</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgSaveMsg(string conv_id, TIMConvType conv_type, Message message, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSaveMsg(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgSaveMsg(string conv_id, TIMConvType conv_type, Message message, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSaveMsg(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 获取历史消息列表
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="get_message_list_param">获取历史消息参数 MsgGetMsgListParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgGetMsgList(string conv_id, TIMConvType conv_type, MsgGetMsgListParam get_message_list_param, ValueCallback<List<Message>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgGetMsgList(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(get_message_list_param)), ValueCallbackInstance<List<Message>>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgGetMsgList(string conv_id, TIMConvType conv_type, MsgGetMsgListParam get_message_list_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgGetMsgList(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(get_message_list_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 消息删除
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message_delete_param">删除消息参数 MsgDeleteParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgDelete(string conv_id, TIMConvType conv_type, MsgDeleteParam message_delete_param, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDelete(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message_delete_param)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgDelete(string conv_id, TIMConvType conv_type, MsgDeleteParam message_delete_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDelete(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message_delete_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 消息删除
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="message_delete_param">删除消息参数 MsgDeleteParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgListDelete(string conv_id, TIMConvType conv_type, List<Message> message_list, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();


            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgListDelete(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message_list)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgListDelete(string conv_id, TIMConvType conv_type, List<Message> message_list, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();


            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgListDelete(conv_id, (int)conv_type, Utils.string2intptr(Utils.ToJson(message_list)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 清除历史消息
        /// </summary>
        /// <param name="conv_id">会话ID</param>
        /// <param name="conv_type">会话类型 TIMConvType</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgClearHistoryMessage(string conv_id, TIMConvType conv_type, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgClearHistoryMessage(conv_id, (int)conv_type, ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgClearHistoryMessage(string conv_id, TIMConvType conv_type, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgClearHistoryMessage(conv_id, (int)conv_type, ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 设置收消息选项
        /// </summary>
        /// <param name="user_id_list">用户ID列表</param>
        /// <param name="opt">接收消息选项 TIMReceiveMessageOpt</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgSetC2CReceiveMessageOpt(List<string> user_id_list, TIMReceiveMessageOpt opt, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSetC2CReceiveMessageOpt(Utils.string2intptr(Utils.ToJson(user_id_list)), (int)opt, ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgSetC2CReceiveMessageOpt(List<string> user_id_list, TIMReceiveMessageOpt opt, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSetC2CReceiveMessageOpt(Utils.string2intptr(Utils.ToJson(user_id_list)), (int)opt, ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 设置C2C收消息选项
        /// </summary>
        /// <param name="user_id_list">用户ID列表</param>
        /// <param name="opt">接收消息选项 TIMReceiveMessageOpt</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgGetC2CReceiveMessageOpt(List<string> user_id_list, ValueCallback<List<GetC2CRecvMsgOptResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgGetC2CReceiveMessageOpt(Utils.string2intptr(Utils.ToJson(user_id_list)), ValueCallbackInstance<List<GetC2CRecvMsgOptResult>>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgGetC2CReceiveMessageOpt(List<string> user_id_list, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgGetC2CReceiveMessageOpt(Utils.string2intptr(Utils.ToJson(user_id_list)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 设置群收消息选项
        /// </summary>
        /// <param name="group_id">用户ID列表</param>
        /// <param name="opt">接收消息选项 TIMReceiveMessageOpt</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgSetGroupReceiveMessageOpt(string group_id, TIMReceiveMessageOpt opt, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSetGroupReceiveMessageOpt(Utils.string2intptr(group_id), (int)opt, ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgSetGroupReceiveMessageOpt(string group_id, TIMReceiveMessageOpt opt, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSetGroupReceiveMessageOpt(Utils.string2intptr(group_id), (int)opt, ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 设置离线推送配置信息（iOS 和 Android 平台专用）
        /// </summary>
        /// <param name="opt">OfflinePushToken</param>
        /// <param name="callback">ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgSetOfflinePushToken(OfflinePushToken json_token,  ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSetOfflinePushToken(Utils.string2intptr(Utils.ToJson(json_token)),  ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgSetOfflinePushToken(OfflinePushToken json_token,  ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSetOfflinePushToken(Utils.string2intptr(Utils.ToJson(json_token)),  ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// APP 检测到应用退后台时可以调用此接口，可以用作桌面应用角标的初始化未读数量（iOS 和 Android 平台专用）。
        /// </summary>
        /// <param name="unread_count">unread_count</param>
        /// <param name="callback">ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgDoBackground(int unread_count,  ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDoBackground(unread_count,  ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgDoBackground(int unread_count,  ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDoBackground(unread_count,  ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        /// <summary>
        /// APP 检测到应用进前台时可以调用此接口（iOS 和 Android 平台专用）。
        /// </summary>
        /// <param name="callback">ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgDoForeground(ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDoForeground(ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgDoForeground(ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDoForeground(ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        
        /// <summary>
        /// 下载多媒体消息
        /// </summary>
        /// <param name="download_param">下载参数 DownloadElemParam</param>
        /// <param name="path">本地路径</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgDownloadElemToPath(DownloadElemParam download_param, string path, ValueCallback<MsgDownloadElemResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDownloadElemToPath(Utils.string2intptr(Utils.ToJson(download_param)), Utils.string2intptr(path), ValueCallbackInstance<MsgDownloadElemResult>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgDownloadElemToPath(DownloadElemParam download_param, string path, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDownloadElemToPath(Utils.string2intptr(Utils.ToJson(download_param)), Utils.string2intptr(path), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 下载合并消息
        /// </summary>
        /// <param name="message">消息体 Message</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgDownloadMergerMessage(Message message, ValueCallback<List<Message>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDownloadMergerMessage(Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<List<Message>>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgDownloadMergerMessage(Message message, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgDownloadMergerMessage(Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 批量发送消息
        /// </summary>
        /// <param name="json_batch_send_param">批量消息体 MsgBatchSendParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgBatchSend(MsgBatchSendParam json_batch_send_param, ValueCallback<List<MsgBatchSendResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgBatchSend(Utils.string2intptr(Utils.ToJson(json_batch_send_param)), ValueCallbackInstance<List<MsgBatchSendResult>>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgBatchSend(MsgBatchSendParam json_batch_send_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgBatchSend(Utils.string2intptr(Utils.ToJson(json_batch_send_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 搜索本地消息
        /// </summary>
        /// <param name="message_search_param">搜索消息参数 MessageSearchParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgSearchLocalMessages(MessageSearchParam message_search_param, ValueCallback<MessageSearchResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSearchLocalMessages(Utils.string2intptr(Utils.ToJson(message_search_param)), ValueCallbackInstance<MessageSearchResult>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgSearchLocalMessages(MessageSearchParam message_search_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSearchLocalMessages(Utils.string2intptr(Utils.ToJson(message_search_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 设置消息本地数据
        /// </summary>
        /// <param name="message">消息体 Message</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult MsgSetLocalCustomData(Message message, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSetLocalCustomData(Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult MsgSetLocalCustomData(Message message, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMMsgSetLocalCustomData(Utils.string2intptr(Utils.ToJson(message)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 创建群
        /// </summary>
        /// <param name="group">创建群信息 CreateGroupParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupCreate(CreateGroupParam group, ValueCallback<CreateGroupResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMGroupCreate(Utils.string2intptr(Utils.ToJson(group)), ValueCallbackInstance<CreateGroupResult>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult GroupCreate(CreateGroupParam group, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMGroupCreate(Utils.string2intptr(Utils.ToJson(group)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 删除群
        /// </summary>
        /// <param name="group_id">群ID</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupDelete(string group_id, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMGroupDelete(Utils.string2intptr(group_id), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }
        public static TIMResult GroupDelete(string group_id, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int timSucc = IMNativeSDK.TIMGroupDelete(Utils.string2intptr(group_id), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)timSucc;
        }

        /// <summary>
        /// 加入群
        /// </summary>
        /// <param name="group_id">群ID</param>
        /// <param name="hello_message">进群打招呼信息</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupJoin(string group_id, string hello_message, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupJoin(Utils.string2intptr(group_id), Utils.string2intptr(hello_message), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupJoin(string group_id, string hello_message, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupJoin(Utils.string2intptr(group_id), Utils.string2intptr(hello_message), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 退出群
        /// </summary>
        /// <param name="group_id">群ID</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupQuit(string group_id, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupQuit(Utils.string2intptr(group_id), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupQuit(string group_id, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupQuit(Utils.string2intptr(group_id), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 邀请用户进群
        /// </summary>
        /// <param name="param">邀请人员信息 GroupInviteMemberParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupInviteMember(GroupInviteMemberParam param, ValueCallback<List<GroupInviteMemberResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupInviteMember(Utils.string2intptr(Utils.ToJson(param)), ValueCallbackInstance<List<GroupInviteMemberResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupInviteMember(GroupInviteMemberParam param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupInviteMember(Utils.string2intptr(Utils.ToJson(param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 剔除群成员
        /// </summary>
        /// <param name="param">删除人员信息 GroupDeleteMemberParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupDeleteMember(GroupDeleteMemberParam param, ValueCallback<List<GroupDeleteMemberResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupDeleteMember(Utils.string2intptr(Utils.ToJson(param)), ValueCallbackInstance<List<GroupDeleteMemberResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupDeleteMember(GroupDeleteMemberParam param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupDeleteMember(Utils.string2intptr(Utils.ToJson(param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取已加入的群组列表
        /// </summary>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupGetJoinedGroupList(ValueCallback<List<GroupBaseInfo>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetJoinedGroupList(ValueCallbackInstance<List<GroupBaseInfo>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupGetJoinedGroupList(ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetJoinedGroupList(ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取群信息
        /// </summary>
        /// <param name="group_id_list">群ID列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupGetGroupInfoList(List<string> group_id_list, ValueCallback<List<GetGroupInfoResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetGroupInfoList(Utils.string2intptr(Utils.ToJson(group_id_list)), ValueCallbackInstance<List<GetGroupInfoResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupGetGroupInfoList(List<string> group_id_list, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetGroupInfoList(Utils.string2intptr(Utils.ToJson(group_id_list)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 修改群信息
        /// </summary>
        /// <param name="json_group_modifyinfo_param">修改信息参数 GroupModifyInfoParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupModifyGroupInfo(GroupModifyInfoParam json_group_modifyinfo_param, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupModifyGroupInfo(Utils.string2intptr(Utils.ToJson(json_group_modifyinfo_param)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupModifyGroupInfo(GroupModifyInfoParam json_group_modifyinfo_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupModifyGroupInfo(Utils.string2intptr(Utils.ToJson(json_group_modifyinfo_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取群成员信息
        /// </summary>
        /// <param name="json_group_getmeminfos_param">修改信息参数 GroupGetMemberInfoListParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupGetMemberInfoList(GroupGetMemberInfoListParam json_group_getmeminfos_param, ValueCallback<GroupGetMemberInfoListResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetMemberInfoList(Utils.string2intptr(Utils.ToJson(json_group_getmeminfos_param)), ValueCallbackInstance<GroupGetMemberInfoListResult>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupGetMemberInfoList(GroupGetMemberInfoListParam json_group_getmeminfos_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetMemberInfoList(Utils.string2intptr(Utils.ToJson(json_group_getmeminfos_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 修改群成员信息
        /// </summary>
        /// <param name="json_group_modifymeminfo_param">修改信息参数 GroupModifyMemberInfoParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupModifyMemberInfo(GroupModifyMemberInfoParam json_group_modifymeminfo_param, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupModifyMemberInfo(Utils.string2intptr(Utils.ToJson(json_group_modifymeminfo_param)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupModifyMemberInfo(GroupModifyMemberInfoParam json_group_modifymeminfo_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupModifyMemberInfo(Utils.string2intptr(Utils.ToJson(json_group_modifymeminfo_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取群未决信息列表
        /// </summary>
        /// <param name="json_group_getpendence_list_param">修改信息参数 GroupPendencyOption</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupGetPendencyList(GroupPendencyOption json_group_getpendence_list_param, ValueCallback<GroupPendencyResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetPendencyList(Utils.string2intptr(Utils.ToJson(json_group_getpendence_list_param)), ValueCallbackInstance<GroupPendencyResult>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupGetPendencyList(GroupPendencyOption json_group_getpendence_list_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetPendencyList(Utils.string2intptr(Utils.ToJson(json_group_getpendence_list_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 上报群未决信息已读
        /// </summary>
        /// <param name="time_stamp">时间戳</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupReportPendencyReaded(long time_stamp, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupReportPendencyReaded(time_stamp, ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupReportPendencyReaded(long time_stamp, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupReportPendencyReaded(time_stamp, ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 处理群未决信息
        /// </summary>
        /// <param name="json_group_handle_pendency_param">处理群未决信息参数 GroupHandlePendencyParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupHandlePendency(GroupHandlePendencyParam json_group_handle_pendency_param, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupHandlePendency(Utils.string2intptr(Utils.ToJson(json_group_handle_pendency_param)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupHandlePendency(GroupHandlePendencyParam json_group_handle_pendency_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupHandlePendency(Utils.string2intptr(Utils.ToJson(json_group_handle_pendency_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取群在线用户数
        /// </summary>
        /// <param name="group_id">群ID</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupGetOnlineMemberCount(string group_id, ValueCallback<GroupGetOnlineMemberCountResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetOnlineMemberCount(Utils.string2intptr(group_id), ValueCallbackInstance<GroupGetOnlineMemberCountResult>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupGetOnlineMemberCount(string group_id, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetOnlineMemberCount(Utils.string2intptr(group_id), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取群在线用户数
        /// </summary>
        /// <param name="group_id">群ID</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupSearchGroups(GroupSearchParam json_group_search_groups_param, ValueCallback<List<GroupDetailInfo>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupSearchGroups(Utils.string2intptr(Utils.ToJson(json_group_search_groups_param)), ValueCallbackInstance<List<GroupDetailInfo>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupSearchGroups(GroupSearchParam json_group_search_groups_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupSearchGroups(Utils.string2intptr(Utils.ToJson(json_group_search_groups_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 搜索群成员
        /// </summary>
        /// <param name="json_group_search_group_members_param">搜索群成员参数 GroupMemberSearchParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupSearchGroupMembers(GroupMemberSearchParam json_group_search_group_members_param, ValueCallback<List<GroupGetOnlineMemberCountResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupSearchGroupMembers(Utils.string2intptr(Utils.ToJson(json_group_search_group_members_param)), ValueCallbackInstance<List<GroupGetOnlineMemberCountResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupSearchGroupMembers(GroupMemberSearchParam json_group_search_group_members_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupSearchGroupMembers(Utils.string2intptr(Utils.ToJson(json_group_search_group_members_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 初始化群自定义属性
        /// </summary>
        /// <param name="group_id">群ID</param>
        /// <param name="json_group_atrributes">群属性参数 GroupAttributes</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupInitGroupAttributes(string group_id, GroupAttributes json_group_atrributes, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupInitGroupAttributes(Utils.string2intptr(group_id), Utils.string2intptr(Utils.ToJson(json_group_atrributes)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupInitGroupAttributes(string group_id, GroupAttributes json_group_atrributes, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupInitGroupAttributes(Utils.string2intptr(group_id), Utils.string2intptr(Utils.ToJson(json_group_atrributes)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 删除群自定义属性
        /// </summary>
        /// <param name="group_id">群ID</param>
        /// <param name="json_keys">属性key列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupDeleteGroupAttributes(string group_id, List<string> json_keys, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupDeleteGroupAttributes(Utils.string2intptr(group_id), Utils.string2intptr(Utils.ToJson(json_keys)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupDeleteGroupAttributes(string group_id, List<string> json_keys, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupDeleteGroupAttributes(Utils.string2intptr(group_id), Utils.string2intptr(Utils.ToJson(json_keys)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 删除群自定义属性
        /// </summary>
        /// <param name="group_id">群ID</param>
        /// <param name="json_keys">属性key列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult GroupGetGroupAttributes(string group_id, List<string> json_keys, ValueCallback<List<GroupAttributes>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetGroupAttributes(Utils.string2intptr(group_id), Utils.string2intptr(Utils.ToJson(json_keys)), ValueCallbackInstance<List<GroupAttributes>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult GroupGetGroupAttributes(string group_id, List<string> json_keys, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMGroupGetGroupAttributes(Utils.string2intptr(group_id), Utils.string2intptr(Utils.ToJson(json_keys)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取用户信息列表
        /// </summary>
        /// <param name="json_get_user_profile_list_param">用户信息列表参数 FriendShipGetProfileListParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ProfileGetUserProfileList(FriendShipGetProfileListParam json_get_user_profile_list_param, ValueCallback<List<UserProfile>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMProfileGetUserProfileList(Utils.string2intptr(Utils.ToJson(json_get_user_profile_list_param)), ValueCallbackInstance<List<UserProfile>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult ProfileGetUserProfileList(FriendShipGetProfileListParam json_get_user_profile_list_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMProfileGetUserProfileList(Utils.string2intptr(Utils.ToJson(json_get_user_profile_list_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 修改自己的信息
        /// </summary>
        /// <param name="json_modify_self_user_profile_param">用户信息列表参数 UserProfileItem</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult ProfileModifySelfUserProfile(UserProfileItem json_modify_self_user_profile_param, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMProfileModifySelfUserProfile(Utils.string2intptr(Utils.ToJson(json_modify_self_user_profile_param)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult ProfileModifySelfUserProfile(UserProfileItem json_modify_self_user_profile_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMProfileModifySelfUserProfile(Utils.string2intptr(Utils.ToJson(json_modify_self_user_profile_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取好友信息
        /// </summary>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipGetFriendProfileList(ValueCallback<List<FriendProfile>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetFriendProfileList(ValueCallbackInstance<List<FriendProfile>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipGetFriendProfileList(ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetFriendProfileList(ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 添加好友
        /// </summary>
        /// <param name="param">添加好友参数 FriendshipAddFriendParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipAddFriend(FriendshipAddFriendParam param, ValueCallback<FriendResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipAddFriend(Utils.string2intptr(Utils.ToJson(param)), ValueCallbackInstance<FriendResult>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipAddFriend(FriendshipAddFriendParam param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipAddFriend(Utils.string2intptr(Utils.ToJson(param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 处理好友申请
        /// </summary>
        /// <param name="param">处理好友申请参数 FriendRespone</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipHandleFriendAddRequest(FriendRespone json_handle_friend_add_param, ValueCallback<FriendResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipHandleFriendAddRequest(Utils.string2intptr(Utils.ToJson(json_handle_friend_add_param)), ValueCallbackInstance<FriendResult>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipHandleFriendAddRequest(FriendRespone json_handle_friend_add_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipHandleFriendAddRequest(Utils.string2intptr(Utils.ToJson(json_handle_friend_add_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 修改好友信息
        /// </summary>
        /// <param name="json_modify_friend_info_param">修改好友信息参数 FriendshipModifyFriendProfileParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipModifyFriendProfile(FriendshipModifyFriendProfileParam json_modify_friend_info_param, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);


            int res = IMNativeSDK.TIMFriendshipModifyFriendProfile(Utils.string2intptr(Utils.ToJson(json_modify_friend_info_param)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipModifyFriendProfile(FriendshipModifyFriendProfileParam json_modify_friend_info_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);


            int res = IMNativeSDK.TIMFriendshipModifyFriendProfile(Utils.string2intptr(Utils.ToJson(json_modify_friend_info_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 删除好友
        /// </summary>
        /// <param name="json_delete_friend_param">删除好友参数 FriendshipDeleteFriendParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipDeleteFriend(FriendshipDeleteFriendParam json_delete_friend_param, ValueCallback<FriendResult> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipDeleteFriend(Utils.string2intptr(Utils.ToJson(json_delete_friend_param)), ValueCallbackInstance<FriendResult>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipDeleteFriend(FriendshipDeleteFriendParam json_delete_friend_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipDeleteFriend(Utils.string2intptr(Utils.ToJson(json_delete_friend_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 检测好友关系
        /// </summary>
        /// <param name="json_check_friend_list_param">检测好友关系参数 FriendshipCheckFriendTypeParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipCheckFriendType(FriendshipCheckFriendTypeParam json_check_friend_list_param, ValueCallback<List<FriendshipCheckFriendTypeResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipCheckFriendType(Utils.string2intptr(Utils.ToJson(json_check_friend_list_param)), ValueCallbackInstance<List<FriendshipCheckFriendTypeResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipCheckFriendType(FriendshipCheckFriendTypeParam json_check_friend_list_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipCheckFriendType(Utils.string2intptr(Utils.ToJson(json_check_friend_list_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 创建好友分组
        /// </summary>
        /// <param name="json_create_friend_group_param">创建好友分组参数 FriendGroupInfo</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipCreateFriendGroup(FriendGroupInfo json_create_friend_group_param, ValueCallback<List<FriendResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipCreateFriendGroup(Utils.string2intptr(Utils.ToJson(json_create_friend_group_param)), ValueCallbackInstance<List<FriendResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipCreateFriendGroup(FriendGroupInfo json_create_friend_group_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipCreateFriendGroup(Utils.string2intptr(Utils.ToJson(json_create_friend_group_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取好友分组列表
        /// </summary>
        /// <param name="json_get_friend_group_list_param">获取好友分组，userID列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipGetFriendGroupList(List<string> json_get_friend_group_list_param, ValueCallback<List<FriendGroupInfo>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetFriendGroupList(Utils.string2intptr(Utils.ToJson(json_get_friend_group_list_param)), ValueCallbackInstance<List<FriendGroupInfo>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipGetFriendGroupList(List<string> json_get_friend_group_list_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetFriendGroupList(Utils.string2intptr(Utils.ToJson(json_get_friend_group_list_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 修改好友分组列表
        /// </summary>
        /// <param name="json_modify_friend_group_param">修改好友分组 FriendshipModifyFriendGroupParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipModifyFriendGroup(FriendshipModifyFriendGroupParam json_modify_friend_group_param, ValueCallback<List<FriendResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipModifyFriendGroup(Utils.string2intptr(Utils.ToJson(json_modify_friend_group_param)), ValueCallbackInstance<List<FriendResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipModifyFriendGroup(FriendshipModifyFriendGroupParam json_modify_friend_group_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipModifyFriendGroup(Utils.string2intptr(Utils.ToJson(json_modify_friend_group_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 删除好友分组列表
        /// </summary>
        /// <param name="json_delete_friend_group_param">删除好友分组 ，userID列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipDeleteFriendGroup(List<string> json_delete_friend_group_param, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipDeleteFriendGroup(Utils.string2intptr(Utils.ToJson(json_delete_friend_group_param)), ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipDeleteFriendGroup(List<string> json_delete_friend_group_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipDeleteFriendGroup(Utils.string2intptr(Utils.ToJson(json_delete_friend_group_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 删除好友分组列表
        /// </summary>
        /// <param name="json_delete_friend_group_param">删除好友分组 ，userID列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipAddToBlackList(List<string> json_add_to_blacklist_param, ValueCallback<List<FriendResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipAddToBlackList(Utils.string2intptr(Utils.ToJson(json_add_to_blacklist_param)), ValueCallbackInstance<List<FriendResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipAddToBlackList(List<string> json_add_to_blacklist_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipAddToBlackList(Utils.string2intptr(Utils.ToJson(json_add_to_blacklist_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取黑名单列表
        /// </summary>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipGetBlackList(ValueCallback<List<FriendProfile>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetBlackList(ValueCallbackInstance<List<FriendProfile>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipGetBlackList(ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetBlackList(ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 从黑名单删除
        /// </summary>
        /// <param name="json_delete_from_blacklist_param">userID列表</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipDeleteFromBlackList(List<string> json_delete_from_blacklist_param, ValueCallback<List<FriendResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipDeleteFromBlackList(Utils.string2intptr(Utils.ToJson(json_delete_from_blacklist_param)), ValueCallbackInstance<List<FriendResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipDeleteFromBlackList(List<string> json_delete_from_blacklist_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipDeleteFromBlackList(Utils.string2intptr(Utils.ToJson(json_delete_from_blacklist_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 获取好友申请未决
        /// </summary>
        /// <param name="json_get_pendency_list_param">好友申请未决参数 FriendshipGetPendencyListParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipGetPendencyList(FriendshipGetPendencyListParam json_get_pendency_list_param, ValueCallback<PendencyPage> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetPendencyList(Utils.string2intptr(Utils.ToJson(json_get_pendency_list_param)), ValueCallbackInstance<PendencyPage>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipGetPendencyList(FriendshipGetPendencyListParam json_get_pendency_list_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetPendencyList(Utils.string2intptr(Utils.ToJson(json_get_pendency_list_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 删除好友申请未决
        /// </summary>
        /// <param name="json_delete_pendency_param">删除好友申请未决参数 FriendshipDeletePendencyParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipDeletePendency(FriendshipDeletePendencyParam json_delete_pendency_param, ValueCallback<List<FriendResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipDeletePendency(Utils.string2intptr(Utils.ToJson(json_delete_pendency_param)), ValueCallbackInstance<List<FriendResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipDeletePendency(FriendshipDeletePendencyParam json_delete_pendency_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipDeletePendency(Utils.string2intptr(Utils.ToJson(json_delete_pendency_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 上报好友申请未决已读
        /// </summary>
        /// <param name="time_stamp">上报时间戳</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipReportPendencyReaded(long time_stamp, ValueCallback<object> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipReportPendencyReaded(time_stamp, ValueCallbackInstance<object>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipReportPendencyReaded(long time_stamp, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipReportPendencyReaded(time_stamp, ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 搜索好友
        /// </summary>
        /// <param name="json_search_friends_param">搜索参数 FriendSearchParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipSearchFriends(FriendSearchParam json_search_friends_param, ValueCallback<List<FriendInfoGetResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipSearchFriends(Utils.string2intptr(Utils.ToJson(json_search_friends_param)), ValueCallbackInstance<List<FriendInfoGetResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipSearchFriends(FriendSearchParam json_search_friends_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipSearchFriends(Utils.string2intptr(Utils.ToJson(json_search_friends_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 搜索好友
        /// </summary>
        /// <param name="json_get_friends_info_param">获取好友信息，好友userIDs</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult FriendshipGetFriendsInfo(List<string> json_get_friends_info_param, ValueCallback<List<FriendInfoGetResult>> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetFriendsInfo(Utils.string2intptr(Utils.ToJson(json_get_friends_info_param)), ValueCallbackInstance<List<FriendInfoGetResult>>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult FriendshipGetFriendsInfo(List<string> json_get_friends_info_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.TIMFriendshipGetFriendsInfo(Utils.string2intptr(Utils.ToJson(json_get_friends_info_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }

        /// <summary>
        /// 实验性接口，开发者一般使用不到，例如私有化等等
        /// </summary>
        /// <param name="json_param">实验性接口参数 ExperimentalAPIReqeustParam</param>
        /// <param name="callback">回调 ValueCallback</param>
        /// <returns><see cref="TIMResult"/></returns>
        public static TIMResult CallExperimentalAPI(ExperimentalAPIReqeustParam json_param, ValueCallback<ReponseInfo> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.callExperimentalAPI(Utils.string2intptr(Utils.ToJson(json_param)), ValueCallbackInstance<ReponseInfo>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }
        public static TIMResult CallExperimentalAPI(ExperimentalAPIReqeustParam json_param, ValueCallback<string> callback)
        {
            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();

            ValuecallbackStore.Add(user_data, callback);

            int res = IMNativeSDK.callExperimentalAPI(Utils.string2intptr(Utils.ToJson(json_param)), ValueCallbackInstance<string>, Utils.string2intptr(user_data));

            return (TIMResult)res;
        }





        /// <summary>
        /// 注册收到新消息回调
        /// <para>如果用户是登录状态，ImSDK收到新消息会通过此接口设置的回调抛出，另外需要注意，抛出的消息不一定是未读的消息 </para>
        /// <para>只是本地曾经没有过的消息（例如在另外一个终端已读，拉取最近联系人消息时可以获取会话最后一条消息，如果本地没有，会通过此方法抛出）</para>
        /// <para>在用户登录之后，ImSDK会拉取离线消息，为了不漏掉消息通知，需要在登录之前注册新消息通知</para>
        /// </summary>
        /// <param name="callback">回调 RecvNewMsgCallback</param>
        public static void AddRecvNewMsgCallback(RecvNewMsgCallback callback)
        {

            string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

            string user_data = fn_name + "_" + Utils.getRandomStr();


            RecvNewMsgCallbackStore = callback;


            IMNativeSDK.TIMAddRecvNewMsgCallback(TIMRecvNewMsgCallbackInstance, Utils.string2intptr(user_data));


        }

        /// <summary>
        /// 移除收到新消息回调
        /// </summary>
        public static void RemoveRecvNewMsgCallback()
        {

            IMNativeSDK.TIMRemoveRecvNewMsgCallback(TIMRecvNewMsgCallbackInstance);
        }


        /// <summary>
        /// 设置消息已读回执回调
        /// <para>发送方发送消息，接收方调用接口[TIMMsgReportReaded]()上报该消息已读，发送方ImSDK会通过此接口设置的回调抛出</para>
        /// </summary>
        /// <param name="callback">回调 MsgReadedReceiptCallback</param>
        public static void SetMsgReadedReceiptCallback(MsgReadedReceiptCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                MsgReadedReceiptCallbackStore = callback;

                IMNativeSDK.TIMSetMsgReadedReceiptCallback(TIMMsgReadedReceiptCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetMsgReadedReceiptCallback(null, Utils.string2intptr(""));
            }

        }

        /// <summary>
        /// 设置接收的消息被撤回回调
        /// <para>发送方发送消息，接收方收到消息。此时发送方调用接口[TIMMsgRevoke]()撤回该消息，接收方的ImSDK会通过此接口设置的回调抛出</para>
        /// </summary>
        /// <param name="callback">回调 MsgRevokeCallback</param>
        public static void SetMsgRevokeCallback(MsgRevokeCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                MsgRevokeCallbackStore = callback;

                IMNativeSDK.TIMSetMsgRevokeCallback(TIMMsgRevokeCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetMsgRevokeCallback(null, Utils.string2intptr(""));
            }



        }


        /// <summary>
        /// 设置消息内元素相关文件上传进度回调
        /// <para>设置消息元素上传进度回调。当消息内包含图片、声音、文件、视频元素时，ImSDK会上传这些文件，并触发此接口设置的回调，用户可以根据回调感知上传的进度</para>
        /// </summary>
        /// <param name="callback">回调 MsgElemUploadProgressCallback</param>
        public static void SetMsgElemUploadProgressCallback(MsgElemUploadProgressCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                MsgElemUploadProgressCallbackStore = callback;

                IMNativeSDK.TIMSetMsgElemUploadProgressCallback(TIMMsgElemUploadProgressCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetMsgElemUploadProgressCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置群组系统消息回调
        /// <para>群组系统消息事件包括 加入群、退出群、踢出群、设置管理员、取消管理员、群资料变更、群成员资料变更。此消息是针对所有群组成员下发的</para>
        /// </summary>
        /// <param name="callback">回调 GroupTipsEventCallback</param>
        public static void SetGroupTipsEventCallback(GroupTipsEventCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                GroupTipsEventCallbackStore = callback;

                IMNativeSDK.TIMSetGroupTipsEventCallback(TIMGroupTipsEventCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetGroupTipsEventCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置群组属性变更回调
        /// <para>某个已加入的群的属性被修改了，会返回所在群组的所有属性（该群所有的成员都能收到）</para>
        /// </summary>
        /// <param name="callback">回调 GroupAttributeChangedCallback</param>
        public static void SetGroupAttributeChangedCallback(GroupAttributeChangedCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                GroupAttributeChangedCallbackStore = callback;

                IMNativeSDK.TIMSetGroupAttributeChangedCallback(TIMGroupAttributeChangedCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetGroupAttributeChangedCallback(null, Utils.string2intptr(""));
            }


        }


        /// <summary>
        /// 设置会话事件回调
        /// <para>会话事件包括：</para>
        /// <para>会话新增</para>
        /// <para>会话删除</para>
        /// <para>会话更新</para>
        /// <para>会话开始</para>
        /// <para>会话结束</para>
        /// <para>任何产生一个新会话的操作都会触发会话新增事件，例如调用接口[TIMConvCreate]()创建会话，接收到未知会话的第一条消息等</para>
        /// <para>任何已有会话变化的操作都会触发会话更新事件，例如收到会话新消息，消息撤回，已读上报等</para>
        /// <para>调用接口[TIMConvDelete]()删除会话成功时会触发会话删除事件</para>
        /// </summary>
        /// <param name="callback">回调 ConvEventCallback</param>
        public static void SetConvEventCallback(ConvEventCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                ConvEventCallbackStore = callback;

                IMNativeSDK.TIMSetConvEventCallback(TIMConvEventCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetConvEventCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置会话未读消息总数变更的回调
        /// </summary>
        /// <param name="callback">回调 ConvTotalUnreadMessageCountChangedCallback</param>
        public static void SetConvTotalUnreadMessageCountChangedCallback(ConvTotalUnreadMessageCountChangedCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                ConvTotalUnreadMessageCountChangedCallbackStore = callback;

                IMNativeSDK.TIMSetConvTotalUnreadMessageCountChangedCallback(TIMConvTotalUnreadMessageCountChangedCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetConvTotalUnreadMessageCountChangedCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置网络连接状态监听回调
        /// <para>当调用接口 Init() 时，ImSDK会去连接云后台。此接口设置的回调用于监听网络连接的状态</para>
        /// <para>网络连接状态包含四个：正在连接、连接失败、连接成功、已连接。这里的网络事件不表示用户本地网络状态，仅指明ImSDK是否与即时通信IM云Server连接状态</para>
        /// <para>可选设置，如果要用户感知是否已经连接服务器，需要设置此回调，用于通知调用者跟通讯后台链接的连接和断开事件，另外，如果断开网络，等网络恢复后会自动重连，自动拉取消息通知用户，用户无需关心网络状态，仅作通知之用</para>
        /// <para>只要用户处于登录状态，ImSDK内部会进行断网重连，用户无需关心</para>
        /// </summary>
        /// <param name="callback">回调 NetworkStatusListenerCallback</param>
        public static void SetNetworkStatusListenerCallback(NetworkStatusListenerCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                NetworkStatusListenerCallbackStore = callback;

                IMNativeSDK.TIMSetNetworkStatusListenerCallback(TIMNetworkStatusListenerCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetNetworkStatusListenerCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置被踢下线通知回调
        ///  <para>用户如果在其他终端登录，会被踢下线，这时会收到用户被踢下线的通知，出现这种情况常规的做法是提示用户进行操作（退出，或者再次把对方踢下线）</para>
        ///  <para>用户如果在离线状态下被踢，下次登录将会失败，可以给用户一个非常强的提醒（登录错误码ERR_IMSDK_KICKED_BY_OTHERS：6208），开发者也可以选择忽略这次错误，再次登录即可</para>
        ///  <para>用户在线情况下的互踢情况：</para>
        ///  <para>用户在设备1登录，保持在线状态下，该用户又在设备2登录，这时用户会在设备1上强制下线，收到 KickedOfflineCallback 回调</para>
        ///  <para>用户在设备1上收到回调后，提示用户，可继续调用login上线，强制设备2下线。这里是在线情况下互踢过程</para>
        ///  <para>用户离线状态互踢:</para>
        ///  <para>用户在设备1登录，没有进行logout情况下进程退出。该用户在设备2登录，此时由于用户不在线，无法感知此事件，</para>
        ///  <para>为了显式提醒用户，避免无感知的互踢，用户在设备1重新登录时，会返回（ERR_IMSDK_KICKED_BY_OTHERS：6208）错误码，表明之前被踢，是否需要把对方踢下线</para>
        ///  <para>如果需要，则再次调用login强制上线，设备2的登录的实例将会收到 KickedOfflineCallback 回调</para>
        /// </summary>
        /// <param name="callback">回调 KickedOfflineCallback</param>
        public static void SetKickedOfflineCallback(KickedOfflineCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                KickedOfflineCallbackStore = callback;

                IMNativeSDK.TIMSetKickedOfflineCallback(TIMKickedOfflineCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetKickedOfflineCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置票据过期回调
        /// <para>用户票据，可能会存在过期的情况，如果用户票据过期，此接口设置的回调会调用</para>
        /// <para>Login()也将会返回70001错误码。开发者可根据错误码或者票据过期回调进行票据更换</para>
        /// </summary>
        /// <param name="callback">回调 UserSigExpiredCallback</param>
        public static void SetUserSigExpiredCallback(UserSigExpiredCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                UserSigExpiredCallbackStore = callback;

                IMNativeSDK.TIMSetUserSigExpiredCallback(TIMUserSigExpiredCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetUserSigExpiredCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置添加好友的回调
        /// <para>此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备添加了好友，B设备ImSDK会收到添加好友的推送，ImSDK通过此回调告知开发者</para>
        /// </summary>
        /// <param name="callback">回调 OnAddFriendCallback</param>
        public static void SetOnAddFriendCallback(OnAddFriendCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                OnAddFriendCallbackStore = callback;

                IMNativeSDK.TIMSetOnAddFriendCallback(TIMOnAddFriendCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetOnAddFriendCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置删除好友的回调
        /// <para>此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备删除了好友，B设备ImSDK会收到删除好友的推送，ImSDK通过此回调告知开发者</para>
        /// </summary>
        /// <param name="callback">回调 OnDeleteFriendCallback</param>
        public static void SetOnDeleteFriendCallback(OnDeleteFriendCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                OnDeleteFriendCallbackStore = callback;

                IMNativeSDK.TIMSetOnDeleteFriendCallback(TIMOnDeleteFriendCallbackInstance, Utils.string2intptr(user_data));

            }
            else
            {
                IMNativeSDK.TIMSetOnDeleteFriendCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置更新好友资料的回调
        /// <para>此回调为了多终端同步。例如A设备、B设备都登录了同一帐号的ImSDK，A设备更新了好友资料，B设备ImSDK会收到更新好友资料的推送，ImSDK通过此回调告知开发者</para>
        /// </summary>
        /// <param name="callback">回调 UpdateFriendProfileCallback</param>
        public static void SetUpdateFriendProfileCallback(UpdateFriendProfileCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                UpdateFriendProfileCallbackStore = callback;

                IMNativeSDK.TIMSetUpdateFriendProfileCallback(TIMUpdateFriendProfileCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetUpdateFriendProfileCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置好友添加请求的回调
        /// <para>当前登入用户设置添加好友需要确认时，如果有用户请求加当前登入用户为好友，会收到好友添加请求的回调，ImSDK通过此回调告知开发者。如果多终端登入同一帐号，每个终端都会收到这个回调</para>
        /// </summary>
        /// <param name="callback">回调 FriendAddRequestCallback</param>
        public static void SetFriendAddRequestCallback(FriendAddRequestCallback callback)
        {
            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                FriendAddRequestCallbackStore = callback;

                IMNativeSDK.TIMSetFriendAddRequestCallback(TIMFriendAddRequestCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetFriendAddRequestCallback(null, Utils.string2intptr(""));
            }

        }

        /// <summary>
        /// 设置好友申请被删除的回调
        /// <para>1. 主动删除好友申请</para>
        /// <para>2. 拒绝好友申请</para>
        /// <para>3. 同意好友申请</para>
        /// <para>4. 申请加别人好友被拒绝</para>
        /// </summary>
        /// <param name="callback">回调 FriendApplicationListDeletedCallback</param>
        public static void SetFriendApplicationListDeletedCallback(FriendApplicationListDeletedCallback callback)
        {

            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                FriendApplicationListDeletedCallbackStore = callback;

                IMNativeSDK.TIMSetFriendApplicationListDeletedCallback(TIMFriendApplicationListDeletedCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetFriendApplicationListDeletedCallback(null, Utils.string2intptr(""));
            }

        }

        /// <summary>
        /// 设置好友申请已读的回调
        /// <para>如果调用 setFriendApplicationRead 设置好友申请列表已读，会收到这个回调（主要用于多端同步）</para>
        /// </summary>
        /// <param name="callback">回调 FriendApplicationListReadCallback</param>
        public static void SetFriendApplicationListReadCallback(FriendApplicationListReadCallback callback)
        {

            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                FriendApplicationListReadCallbackStore = callback;

                IMNativeSDK.TIMSetFriendApplicationListReadCallback(TIMFriendApplicationListReadCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetFriendApplicationListReadCallback(null, Utils.string2intptr(""));
            }

        }

        /// <summary>
        /// 设置黑名单新增的回调
        /// </summary>
        /// <param name="callback">回调 FriendBlackListAddedCallback</param>
        public static void SetFriendBlackListAddedCallback(FriendBlackListAddedCallback callback)
        {



            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                FriendBlackListAddedCallbackStore = callback;
                IMNativeSDK.TIMSetFriendBlackListAddedCallback(TIMFriendBlackListAddedCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetFriendBlackListAddedCallback(null, Utils.string2intptr(""));
            }


        }

        /// <summary>
        /// 设置黑名单删除的回调
        /// </summary>
        /// <param name="callback">回调 FriendBlackListDeletedCallback</param>
        public static void SetFriendBlackListDeletedCallback(FriendBlackListDeletedCallback callback)
        {



            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                FriendBlackListDeletedCallbackStore = callback;
                IMNativeSDK.TIMSetFriendBlackListDeletedCallback(TIMFriendBlackListDeletedCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetFriendBlackListDeletedCallback(null, Utils.string2intptr(""));
            }



        }

        /// <summary>
        /// 设置日志回调
        /// <para>设置日志监听的回调之后，ImSDK内部的日志会回传到此接口设置的回调</para>
        /// <para>开发者可以通过接口SetConfig()配置哪些日志级别的日志回传到回调函数</para>
        /// </summary>
        /// <param name="callback">回调 FriendBlackListDeletedCallback</param>
        public static void SetLogCallback(LogCallback callback)
        {

            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                LogCallbackStore = callback;

                IMNativeSDK.TIMSetLogCallback(TIMLogCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetLogCallback(null, Utils.string2intptr(""));
            }

        }

        /// <summary>
        /// 设置消息在云端被修改后回传回来的消息更新通知回调
        /// <para> 当您发送的消息在服务端被修改后，ImSDK会通过该回调通知给您 </para>
        /// <para> 您可以在您自己的服务器上拦截所有即时通信IM消息 [发单聊消息之前回调](https://cloud.tencent.com/document/product/269/1632)</para>
        /// <para> 设置成功之后，即时通信IM服务器会将您的用户发送的每条消息都同步地通知给您的业务服务器</para>
        /// <para> 您的业务服务器可以对该条消息进行修改（例如过滤敏感词），如果您的服务器对消息进行了修改，ImSDK就会通过此回调通知您</para>
        /// </summary>
        /// <param name="callback">回调 FriendBlackListDeletedCallback</param>
        public static void SetMsgUpdateCallback(MsgUpdateCallback callback)
        {

            if (callback != null)
            {
                string fn_name = System.Reflection.MethodBase.GetCurrentMethod().Name;

                string user_data = fn_name + "_" + Utils.getRandomStr();

                MsgUpdateCallbackStore = callback;

                IMNativeSDK.TIMSetMsgUpdateCallback(TIMMsgUpdateCallbackInstance, Utils.string2intptr(user_data));
            }
            else
            {
                IMNativeSDK.TIMSetMsgUpdateCallback(null, Utils.string2intptr(""));
            }

        }



        [MonoPInvokeCallback(typeof(IMNativeSDK.CommonValueCallback))]
        private static void ValueCallbackInstance<T> (int code, IntPtr desc, IntPtr json_param, IntPtr user_data)
        {

            string user_data_string = Utils.intptr2string(user_data);
            string desc_string = Utils.intptr2string(desc);
            T param = Utils.FromJson<T>(Utils.intptr2string(json_param));
            mainSyncContext.Send(threadOperation<T>, new CallbackConvert<T>(code, "ValueCallback", param, user_data_string, desc_string));
        }
        static private void threadOperation<T>(object obj)
        {
            CallbackConvert<T> data = (CallbackConvert<T>)obj;
            try
            {
                switch (data.type)
                {
                    case "ValueCallback":
                        if (ValuecallbackStore.ContainsKey(data.user_data))
                        {
                            if (ValuecallbackStore.TryGetValue(data.user_data, out object callbackObj))
                            {
                                ValueCallback<T> callback = (ValueCallback<T>) callbackObj;
                                callback(data.code, data.desc, data.data, data.user_data);
                                ValuecallbackStore.Remove(data.user_data);
                            }

                        };
                        break;
                    case "TIMRecvNewMsgCallback":
                        if (RecvNewMsgCallbackStore != null)
                        {
                            RecvNewMsgCallbackStore(Utils.FromJson<List<Message>>((string)(object) data.data), data.user_data);
                        }
                        break;
                    case "TIMMsgReadedReceiptCallback":
                        if (MsgReadedReceiptCallbackStore != null)
                        {
                            MsgReadedReceiptCallbackStore(Utils.FromJson<List<MessageReceipt>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMMsgRevokeCallback":
                        if (MsgRevokeCallbackStore != null)
                        {
                            MsgRevokeCallbackStore(Utils.FromJson<List<MsgLocator>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMMsgElemUploadProgressCallback":
                        if (MsgElemUploadProgressCallbackStore != null)
                        {
                            MsgElemUploadProgressCallbackStore(Utils.FromJson<Message>((string)(object) data.data), data.index, data.cur_size, data.total_size, data.user_data);

                        }
                        break;
                    case "TIMGroupTipsEventCallback":

                        if (GroupTipsEventCallbackStore != null)
                        {
                            GroupTipsEventCallbackStore(Utils.FromJson<GroupTipsElem>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMGroupAttributeChangedCallback":

                        if (GroupAttributeChangedCallbackStore != null)
                        {
                            GroupAttributeChangedCallbackStore(data.group_id, Utils.FromJson<List<GroupAttributes>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMConvEventCallback":

                        if (ConvEventCallbackStore != null)
                        {
                            ConvEventCallbackStore((TIMConvEvent)data.conv_event, Utils.FromJson<List<ConvInfo>>((string)(object) data.data), data.user_data);

                        }


                        break;
                    case "TIMConvTotalUnreadMessageCountChangedCallback":

                        if (ConvTotalUnreadMessageCountChangedCallbackStore != null)
                        {
                            ConvTotalUnreadMessageCountChangedCallbackStore(data.code, data.user_data);

                        }
                        break;
                    case "TIMNetworkStatusListenerCallback":

                        if (NetworkStatusListenerCallbackStore != null)
                        {
                            NetworkStatusListenerCallbackStore((TIMNetworkStatus)data.code, data.index, data.desc, data.user_data);

                        }
                        break;
                    case "TIMKickedOfflineCallback":

                        if (KickedOfflineCallbackStore != null)
                        {
                            KickedOfflineCallbackStore(data.user_data);

                        }
                        break;
                    case "TIMUserSigExpiredCallback":

                        if (UserSigExpiredCallbackStore != null)
                        {
                            UserSigExpiredCallbackStore(data.user_data);

                        }

                        break;
                    case "TIMOnAddFriendCallback":

                        if (OnAddFriendCallbackStore != null)
                        {
                            OnAddFriendCallbackStore(Utils.FromJson<List<string>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMOnDeleteFriendCallback":
                        if (OnDeleteFriendCallbackStore != null)
                        {
                            OnDeleteFriendCallbackStore(Utils.FromJson<List<string>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMUpdateFriendProfileCallback":

                        if (UpdateFriendProfileCallbackStore != null)
                        {
                            UpdateFriendProfileCallbackStore(Utils.FromJson<List<FriendProfileItem>>((string)(object) data.data), data.user_data);

                        }
                        break;

                    case "TIMFriendAddRequestCallback":

                        if (FriendAddRequestCallbackStore != null)
                        {
                            FriendAddRequestCallbackStore(Utils.FromJson<List<FriendAddPendency>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMFriendApplicationListDeletedCallback":

                        if (FriendApplicationListDeletedCallbackStore != null)
                        {
                            FriendApplicationListDeletedCallbackStore(Utils.FromJson<List<string>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMFriendApplicationListReadCallback":

                        if (FriendApplicationListReadCallbackStore != null)
                        {
                            FriendApplicationListReadCallbackStore(data.user_data);

                        }
                        break;
                    case "TIMFriendBlackListAddedCallback":

                        if (FriendBlackListAddedCallbackStore != null)
                        {
                            FriendBlackListAddedCallbackStore(Utils.FromJson<List<FriendProfile>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMFriendBlackListDeletedCallback":

                        if (FriendBlackListDeletedCallbackStore != null)
                        {
                            FriendBlackListDeletedCallbackStore(Utils.FromJson<List<string>>((string)(object) data.data), data.user_data);

                        }
                        break;
                    case "TIMLogCallback":

                        if (LogCallbackStore != null)
                        {
                            LogCallbackStore((TIMLogLevel)data.code, (string)(object) data.data, data.user_data);
                        }
                        break;
                    case "TIMMsgUpdateCallback":

                        if (MsgUpdateCallbackStore != null)
                        {
                            MsgUpdateCallbackStore(Utils.FromJson<List<Message>>((string)(object) data.data), data.user_data);
                        }
                        break;

                }
            }
            catch (System.Exception error)
            {
                Debug.LogError(error);
            }

        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMRecvNewMsgCallback))]
        private static void TIMRecvNewMsgCallbackInstance(IntPtr json_msg_array, IntPtr user_data)
        {

            try
            {
                string json_msg_array_string = Utils.intptr2string(json_msg_array);

                string user_data_string = Utils.intptr2string(user_data);




                mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMRecvNewMsgCallback", json_msg_array_string, user_data_string, ""));
            }
            catch (Exception e)
            {
                Utils.Log("重点关注，回调解析失败" + e.ToString());
            }

        }


        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMMsgReadedReceiptCallback))]
        private static void TIMMsgReadedReceiptCallbackInstance(IntPtr json_msg_readed_receipt_array, IntPtr user_data)
        {

            string json_msg_readed_receipt_array_string = Utils.intptr2string(json_msg_readed_receipt_array);

            string user_data_string = Utils.intptr2string(user_data);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMMsgReadedReceiptCallback", json_msg_readed_receipt_array_string, user_data_string, ""));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMMsgRevokeCallback))]
        private static void TIMMsgRevokeCallbackInstance(IntPtr json_msg_locator_array, IntPtr user_data)
        {
            string json_msg_locator_array_string = Utils.intptr2string(json_msg_locator_array);

            string user_data_string = Utils.intptr2string(user_data);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMMsgRevokeCallback", json_msg_locator_array_string, user_data_string, ""));


        }


        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMMsgElemUploadProgressCallback))]
        private static void TIMMsgElemUploadProgressCallbackInstance(IntPtr json_msg, int index, int cur_size, int total_size, IntPtr user_data)
        {
            string json_msg_string = Utils.intptr2string(json_msg);

            string user_data_string = Utils.intptr2string(user_data);




            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMMsgElemUploadProgressCallback", json_msg_string, user_data_string, "", index, cur_size, total_size));


        }
        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMGroupTipsEventCallback))]
        private static void TIMGroupTipsEventCallbackInstance(IntPtr json_group_tip_array, IntPtr user_data)
        {
            string json_group_tip_array_string = Utils.intptr2string(json_group_tip_array);

            string user_data_string = Utils.intptr2string(user_data);


            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMGroupTipsEventCallback", json_group_tip_array_string, user_data_string, ""));



        }


        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMGroupAttributeChangedCallback))]
        private static void TIMGroupAttributeChangedCallbackInstance(IntPtr group_id, IntPtr json_group_attibute_array, IntPtr user_data)
        {
            string json_group_attibute_array_string = Utils.intptr2string(json_group_attibute_array);

            string group_id_string = Utils.intptr2string(group_id);

            string user_data_string = Utils.intptr2string(user_data);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMGroupAttributeChangedCallback", json_group_attibute_array_string, user_data_string, "", 0, 0, 0, group_id_string));


        }
        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMConvEventCallback))]
        private static void TIMConvEventCallbackInstance(int conv_event, IntPtr json_conv_array, IntPtr user_data)
        {
            string json_conv_array_string = Utils.intptr2string(json_conv_array);

            string user_data_string = Utils.intptr2string(user_data);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMConvEventCallback", json_conv_array_string, user_data_string, "", 0, 0, 0, "", conv_event));



        }


        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMConvTotalUnreadMessageCountChangedCallback))]
        private static void TIMConvTotalUnreadMessageCountChangedCallbackInstance(int total_unread_count, IntPtr user_data)
        {

            string user_data_string = Utils.intptr2string(user_data);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(total_unread_count, "TIMConvTotalUnreadMessageCountChangedCallback", "", user_data_string));



        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMNetworkStatusListenerCallback))]
        private static void TIMNetworkStatusListenerCallbackInstance(int status, int code, IntPtr desc, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string desc_string = Utils.intptr2string(desc);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(status, "TIMNetworkStatusListenerCallback", "", user_data_string, desc_string, code));



        }
        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMKickedOfflineCallback))]
        private static void TIMKickedOfflineCallbackInstance(IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMKickedOfflineCallback", "", user_data_string));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMUserSigExpiredCallback))]
        private static void TIMUserSigExpiredCallbackInstance(IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);




            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMUserSigExpiredCallback", "", user_data_string));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMOnAddFriendCallback))]
        private static void TIMOnAddFriendCallbackInstance(IntPtr json_identifier_array, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string json_identifier_array_string = Utils.intptr2string(json_identifier_array);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMOnAddFriendCallback", json_identifier_array_string, user_data_string));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMOnDeleteFriendCallback))]
        private static void TIMOnDeleteFriendCallbackInstance(IntPtr json_identifier_array, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string json_identifier_array_string = Utils.intptr2string(json_identifier_array);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMOnDeleteFriendCallback", json_identifier_array_string, user_data_string));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMUpdateFriendProfileCallback))]
        private static void TIMUpdateFriendProfileCallbackInstance(IntPtr json_friend_profile_update_array, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string json_friend_profile_update_array_string = Utils.intptr2string(json_friend_profile_update_array);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMUpdateFriendProfileCallback", json_friend_profile_update_array_string, user_data_string));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMFriendAddRequestCallback))]
        private static void TIMFriendAddRequestCallbackInstance(IntPtr json_friend_add_request_pendency_array, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string json_friend_add_request_pendency_array_string = Utils.intptr2string(json_friend_add_request_pendency_array);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMFriendAddRequestCallback", json_friend_add_request_pendency_array_string, user_data_string));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMFriendApplicationListDeletedCallback))]
        private static void TIMFriendApplicationListDeletedCallbackInstance(IntPtr json_identifier_array, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string json_identifier_array_string = Utils.intptr2string(json_identifier_array);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMFriendApplicationListDeletedCallback", json_identifier_array_string, user_data_string));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMFriendApplicationListReadCallback))]
        private static void TIMFriendApplicationListReadCallbackInstance(IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMFriendApplicationListReadCallback", "", user_data_string));


        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMFriendBlackListAddedCallback))]
        private static void TIMFriendBlackListAddedCallbackInstance(IntPtr json_friend_black_added_array, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string json_friend_black_added_array_string = Utils.intptr2string(json_friend_black_added_array);




            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMFriendBlackListAddedCallback", json_friend_black_added_array_string, user_data_string));



        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMFriendBlackListDeletedCallback))]
        private static void TIMFriendBlackListDeletedCallbackInstance(IntPtr json_identifier_array, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string json_identifier_array_string = Utils.intptr2string(json_identifier_array);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMFriendBlackListDeletedCallback", json_identifier_array_string, user_data_string));




        }

        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMLogCallback))]
        private static void TIMLogCallbackInstance(int level, IntPtr log, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);


            string log_string = Utils.intptr2string(log);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(level, "TIMLogCallback", log_string, user_data_string));


        }





        [MonoPInvokeCallback(typeof(IMNativeSDK.TIMMsgUpdateCallback))]
        public static void TIMMsgUpdateCallbackInstance(IntPtr json_msg_array, IntPtr user_data)
        {
            string user_data_string = Utils.intptr2string(user_data);

            string json_msg_array_string = Utils.intptr2string(json_msg_array);



            mainSyncContext.Send(threadOperation<string>, new CallbackConvert<string>(0, "TIMMsgUpdateCallback", json_msg_array_string, user_data_string));


        }
    }
}

