using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.native;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using com.tencent.imsdk.unity.utils;
using com.tencent.imsdk.unity.callback;
using System;
using System.Text;
using AOT;
using Newtonsoft.Json;
using demo.tencent.im.unity;
using System.Reflection;
using UnityEngine.UI;
// 部分接口测试

public class TestApi : MonoBehaviour
{


    public static float x = 10;



    public static float itemw = (UnityEngine.Screen.width - 30 - 22) / 2;

    public static float itemh = 60;

    public static string data = "";

    public static Vector2 scrollPosition = Vector2.zero;

    public static string userid = ImConfig.user_id;

    public static string touserid = ImConfig.touserid;

    public static string sdkappid = ImConfig.sdk_app_id.ToString();

    public static string user_sig = ImConfig.user_sig;

    public static Dictionary<string, string> config = new Dictionary<string, string>{
        {
            "初始化", "Init"

       },
        {
            "登录IM", "Login"

       },
       {
            "获取登录状态", "GetLoginStatus"

       },
       {
           "获取登录用户", "GetLoginUserID"
       },
       {
           "登出", "Logout"
       },
       {
           "获取会话列表", "ConvGetConvList"
       },
       {
           "删除会话", "ConvDelete"
       },
       {
           "获取会话详情", "ConvGetConvInfo"
       },
       {
           "设置会话草稿", "ConvSetDraft"
       },
       {
           "取消会话草稿", "ConvCancelDraft"
       },
       {
           "会话置顶", "ConvPinConversation"
       },
       {
           "获取全部未读数", "ConvGetTotalUnreadMessageCount"
       },
       {
           "发送消息", "MsgSendMessage"
       },
       {
           "取消发送消息", "MsgCancelSend"
       },
       {
           "查找本地消息", "MsgFindMessages"
       },
       {
           "标记会话（消息）已读", "MsgReportReaded"
       },
       {
           "标记所有会话已读", "MsgMarkAllMessageAsRead"
       },
       {
           "消息撤回", "MsgRevoke"
       },
       {
           "通过消息定位查找消息", "MsgFindByMsgLocatorList"
       },
       {
           "批量导入消息", "MsgImportMsgList"
       },
       {
           "保存消息", "MsgSaveMsg"
       },
       {
           "获取历史消息列表", "MsgGetMsgList"
       },
       {
           "删除消息", "MsgDelete"
       },
       {
           "删除消息列表", "MsgListDelete"
       },
       {
           "清楚历史消息", "MsgClearHistoryMessage"
       },
       {
           "设置c2c消息接收选项", "MsgSetC2CReceiveMessageOpt"
       },
       {
           "获取c2c消息接收选项", "MsgGetC2CReceiveMessageOpt"
       },
       {
           "设置群组消息接收选项", "MsgSetGroupReceiveMessageOpt"
       },
       {
           "下载消息附件", "MsgDownloadElemToPath"
       },
       {
           "下载转发消息", "MsgDownloadMergerMessage"
       },
       {
           "批量发送消息", "MsgBatchSend"
       },
       {
           "关键字搜索本地消息", "MsgSearchLocalMessages"
       },
       {
           "创建群", "GroupCreate"
       },
       {
           "删除群", "GroupDelete"
       },
       {
           "卸载SDK", "Uninit"
       },
       {
           "获取SDK版本", "GetSDKVersion"
       },
       {
           "获取服务端时间", "GetServerTime"
       },
       {
           "加群", "GroupJoin"
       },
       {
           "修改群成员信息", "GroupModifyMemberInfo"
       },
       {
           "修改个人资料", "ProfileModifySelfUserProfile"
       },
       {
           "修改好友资料", "FriendshipModifyFriendProfile"
       },
       {
           "获取好友资料", "FriendshipGetFriendsInfo"
       },
       {
           "加入黑名单", "FriendshipAddToBlackList"
       },
       {
           "获取更多历史消息", "MsgGetMoreMsgList"
       },
       {
           "添加好友", "FriendshipAddFriend"
       }
    };

    void Start()
    {



    }
    void OnDestroy()
    {
        TencentIMSDK.Uninit();
    }
    // Update is called once per frame
    void Update()
    {
    }




    public static void AddListeners()
    {
        TencentIMSDK.AddRecvNewMsgCallback(RecvNewMsgCallback); // 接收消息事件
        // TencentIMSDK.SetMsgReadedReceiptCallback(MsgReadedReceiptCallback); // 消息已读回调
        // TencentIMSDK.SetMsgRevokeCallback(MsgRevokeCallback); // 消息撤回回调
        // TencentIMSDK.SetMsgElemUploadProgressCallback(MsgElemUploadProgressCallback); // 多媒体消息发送进度回调
        // TencentIMSDK.SetGroupTipsEventCallback(GroupTipsEventCallback); // 群tips回调
        // TencentIMSDK.SetGroupAttributeChangedCallback(GroupAttributeChangedCallback); // 群属性改变
        addStringDataToConsole("Listeners add success");
    }





    public static void GroupAttributeChangedCallback(string group_id, List<GroupAttributes> group_attributes, string user_data)
    {
        addStringDataToConsole("SetGroupAttributeChangedCallback called " + JsonConvert.SerializeObject(group_attributes[0]));
    }
    public static void GroupTipsEventCallback(GroupTipsElem tips, string user_data)
    {
        addStringDataToConsole("SetGroupTipsEventCallback called " + JsonConvert.SerializeObject(tips));
    }
    public static void MsgElemUploadProgressCallback(Message message, int index, int cur_size, int total_size, string user_data)
    {
        addStringDataToConsole("SetMsgElemUploadProgressCallback called " + cur_size.ToString() + "/" + total_size.ToString());
    }
    public static void MsgRevokeCallback(List<MsgLocator> msg_locator, string user_data)
    {
        addStringDataToConsole("SetMsgRevokeCallback called " + JsonConvert.SerializeObject(msg_locator[0]));
    }
    public static void MsgReadedReceiptCallback(List<MessageReceipt> message_receipt, string user_data)
    {
        addStringDataToConsole("SetMsgReadedReceiptCallback called " + JsonConvert.SerializeObject(message_receipt[0]));
    }
    public static void CustomValueCallback(int code, string desc, string json_param, string user_data)
    {
        addStringDataToConsole("code: " + code.ToString() + " user_data: " + user_data + " json_param: " + json_param + " desc: " + desc);
    }
    public static void RecvNewMsgCallback(List<Message> message, string user_data)
    {
        addStringDataToConsole("AddRecvNewMsgCallback called " + JsonConvert.SerializeObject(message[0]));
        addCallbackDataToConsole(JsonConvert.SerializeObject(message[0]), user_data);
    }

    public static void LogCallback(TIMLogLevel logLevel, string log, string user_data)
    {

        addStringDataToConsole("LogCallback called log：" + log + "user_data :" + user_data);
    }
    public static void ConvEventCallback(TIMConvEvent conv_event, List<ConvInfo> conv_list, string user_data)
    {
        addStringDataToConsole("ConvEventCallback called " + "user_data :" + user_data);
    }


    public static void addDataToConsole(TIMResult res)
    {
        data += ("Synchronize return: " + ((int)res).ToString() + " ");
    }
    public static void addAsyncDataToConsole(int code, string desc, string json_param, string user_data)
    {
        data += (user_data + "Asynchronous return: " + "code: " + code.ToString() + " desc:" + desc + " json_param: " + json_param + " ");
    }
    public static void addCallbackDataToConsole(string json_param, string user_data)
    {
        data += (user_data + " callback: " + json_param + " ");
    }
    public static void addStringDataToConsole(string d)
    {
        data += (d + " ");
    }
    public static void Login()
    {
        if (userid == "" || user_sig == "")
        {
            addStringDataToConsole("input a userid and user_sig first");
            return;
        }
        // 业务可以替换自己的 sdkappid
        TIMResult res = TencentIMSDK.Login(userid, user_sig, addAsyncDataToConsole);
        addDataToConsole(res);
    }

    public static void Init()
    {
        SdkConfig sdkConfig = new SdkConfig();

        sdkConfig.sdk_config_config_file_path = Application.persistentDataPath + "/TIM-Config";

        sdkConfig.sdk_config_log_file_path = Application.persistentDataPath + "/TIM-Log";

        if (sdkappid == "")
        {
            addStringDataToConsole("input a sdkappid first");
            return;
        }

        TIMResult res = TencentIMSDK.Init(long.Parse(sdkappid), sdkConfig);
        addDataToConsole(res);
        AddListeners();
    }

    void renderBtns()
    {
        List<string> list = new List<string>(config.Keys);
        for (int i = 0; i < list.Count; i++)
        {

            float renderx = i % 2 == 0 ? x : 20 + itemw;
            float rendery = i % 2 == 0 ? 690 + (itemh + 10) * (i / 2) : 690 + (itemh + 10) * ((i - 1) / 2);

            if (GUI.Button(new Rect(renderx, rendery, itemw, itemh), config[list[i]]))
            {
                var t = Type.GetType("TestApi");
                // object obj = Activator.CreateInstance(t);
                object[] paras = new object[0];
                MethodInfo method = t.GetMethod(config[list[i]]);
                method.Invoke(null, paras);
            }

        }
    }


    void renderGame()
    {
        GUIStyle tstyle = new GUIStyle(GUI.skin.textField);

        tstyle.wordWrap = true;


        data = GUI.TextArea(new Rect(10, 10, UnityEngine.Screen.width - 40, 390), data, tstyle);

        decimal hc = config.Keys.Count / 2;

        decimal scrollHeight = Math.Ceiling(hc) * 50 + 700;


        GUI.Label(new Rect(10, 410, 100, 60), "Login ID");

        userid = GUI.TextField(new Rect(110, 410, UnityEngine.Screen.width - 40 - 100, 60), userid, tstyle);


        GUI.Label(new Rect(10, 480, 100, 60), "Receive ID");

        touserid = GUI.TextField(new Rect(110, 480, UnityEngine.Screen.width - 40 - 100, 60), touserid, tstyle);


        GUI.Label(new Rect(10, 550, 100, 60), "userSig");

        user_sig = GUI.TextField(new Rect(110, 550, UnityEngine.Screen.width - 40 - 100, 60), user_sig, tstyle);

        GUI.Label(new Rect(10, 620, 100, 60), "sdkappid");

        sdkappid = GUI.TextField(new Rect(110, 620, UnityEngine.Screen.width - 40 - 100, 60), sdkappid, tstyle);


        // 创建console区域

        scrollPosition = GUI.BeginScrollView(new Rect(0, 690, UnityEngine.Screen.width, UnityEngine.Screen.height - 690), scrollPosition, new Rect(0, 690, UnityEngine.Screen.width - 16, (float)scrollHeight), false, false);

        renderBtns();

        // 结束滚动视图
        GUI.EndScrollView();

        // 渲染清除button

    }

    public static void FriendshipAddFriend()
    {
        FriendshipAddFriendParam param = new FriendshipAddFriendParam();
        param.friendship_add_friend_param_identifier = "6666";
        param.friendship_add_friend_param_friend_type = TIMFriendType.FriendTypeBoth;
        param.friendship_add_friend_param_add_wording = "hello";
        TIMResult res = TencentIMSDK.FriendshipAddFriend(param, addAsyncDataToConsole);
        addDataToConsole(res);
    }
    public static void GetLoginStatus()
    {
        TIMLoginStatus res = TencentIMSDK.GetLoginStatus();
        addStringDataToConsole(((int)res).ToString());


    }
    public static void Logout()
    {
        TIMResult res = TencentIMSDK.Logout(addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }

    public static void GetLoginUserID()
    {
        StringBuilder userId = new StringBuilder(128);

        TIMResult res = TencentIMSDK.GetLoginUserID(userId);

        addStringDataToConsole(userId.ToString());
        addDataToConsole(res);

    }
    public static void ConvGetConvList()
    {
        TIMResult res = TencentIMSDK.ConvGetConvList(addAsyncDataToConsole);
        addDataToConsole(res);
    }
    public static void ConvDelete()
    {
        string conv_id = "287646";

        TIMResult res = TencentIMSDK.ConvDelete(conv_id, TIMConvType.kTIMConv_C2C, addAsyncDataToConsole);
        addDataToConsole(res);
    }
    public static void ConvGetConvInfo()
    {
        List<ConvParam> list = new List<ConvParam>();
        ConvParam conv1 = new ConvParam();
        conv1.get_conversation_list_param_conv_id = "im_discuss_TBcYzRWnAp6dmiNT";
        conv1.get_conversation_list_param_conv_type = TIMConvType.kTIMConv_Group;
        list.Add(conv1);
        ConvParam conv2 = new ConvParam();
        conv2.get_conversation_list_param_conv_id = "287646";
        conv2.get_conversation_list_param_conv_type = TIMConvType.kTIMConv_C2C;
        list.Add(conv2);
        TIMResult res = TencentIMSDK.ConvGetConvInfo(list, addAsyncDataToConsole);
        addDataToConsole(res);
    }
    public static void ConvSetDraft()
    {
        string conv_id = "287646";
        DraftParam param = new DraftParam();
        param.draft_user_define = "你好啊";
        param.draft_edit_time = (ulong)new DateTimeOffset(DateTime.UtcNow).ToUnixTimeMilliseconds();
        Message message = new Message();
        param.draft_msg = message;
        TIMResult res = TencentIMSDK.ConvSetDraft(conv_id, TIMConvType.kTIMConv_C2C, param);
        addDataToConsole(res);
    }
    public static void ConvCancelDraft()
    {
        string conv_id = "287646";
        TIMResult res = TencentIMSDK.ConvCancelDraft(conv_id, TIMConvType.kTIMConv_C2C);
        addDataToConsole(res);
    }
    public static void ConvPinConversation()
    {
        string conv_id = "287646";
        TIMResult res = TencentIMSDK.ConvPinConversation(conv_id, TIMConvType.kTIMConv_C2C, true, addAsyncDataToConsole);
        addDataToConsole(res);
    }
    public static void ConvGetTotalUnreadMessageCount()
    {
        TIMResult res = TencentIMSDK.ConvGetTotalUnreadMessageCount(addAsyncDataToConsole);
        addDataToConsole(res);
    }
    public static void MsgSendMessage()
    {
        string conv_id = touserid;
        Message message = new Message();
        message.message_conv_id = conv_id;
        message.message_conv_type = TIMConvType.kTIMConv_C2C;
        List<Elem> messageElems = new List<Elem>();
        Elem textMessage = new Elem();
        textMessage.elem_type = TIMElemType.kTIMElem_Text;
        textMessage.text_elem_content = "圣女峰";
        messageElems.Add(textMessage);
        message.message_elem_array = messageElems;
        message.message_cloud_custom_str = "unity local custom data";
        StringBuilder messageId = new StringBuilder(128);

        TIMResult res = TencentIMSDK.MsgSendMessage(conv_id, TIMConvType.kTIMConv_C2C, message, messageId, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        Utils.Log(messageId.ToString()); // 同步返回消息ID
        addDataToConsole(res);
        addStringDataToConsole(messageId.ToString());
    }
    public static void MsgCancelSend()
    {
        string conv_id = "287646";
        string message_id = "144115263066194686-1638863822-3314274833";
        TIMResult res = TencentIMSDK.MsgCancelSend(conv_id, TIMConvType.kTIMConv_C2C, message_id, addAsyncDataToConsole);
        addDataToConsole(res);
    }
    public static void MsgFindMessages()
    {
        string message_id = "144115263066194686-1638863822-3314274833";
        List<string> message_id_array = new List<string>();
        message_id_array.Add(message_id);
        TIMResult res = TencentIMSDK.MsgFindMessages(message_id_array, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgReportReaded()
    {
        string conv_id = "287646";
        TIMResult res = TencentIMSDK.MsgReportReaded(conv_id, TIMConvType.kTIMConv_C2C, null, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgMarkAllMessageAsRead()
    {
        TIMResult res = TencentIMSDK.MsgMarkAllMessageAsRead(addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgRevoke()
    {
        string conv_id = "287646";
        Message message = new Message(); // 这里的消息可以是其他接口返回的实例，如消息列表接口

        TIMResult res = TencentIMSDK.MsgRevoke(conv_id, TIMConvType.kTIMConv_C2C, message, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgFindByMsgLocatorList()
    {
        string conv_id = "287646";
        MsgLocator message_locator = new MsgLocator(); // 这里的消息可以是其他接口返回的实例，如消息列表接口

        TIMResult res = TencentIMSDK.MsgFindByMsgLocatorList(conv_id, TIMConvType.kTIMConv_C2C, message_locator, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgImportMsgList()
    {
        string conv_id = "287646";

        List<Message> message_list = new List<Message>();

        message_list.Add(new Message());

        TIMResult res = TencentIMSDK.MsgImportMsgList(conv_id, TIMConvType.kTIMConv_C2C, message_list, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgSaveMsg()
    {
        string conv_id = "287646";

        Message message = new Message(); // 这里的消息可以是其他接口返回的实例，如消息列表接口

        TIMResult res = TencentIMSDK.MsgSaveMsg(conv_id, TIMConvType.kTIMConv_C2C, message, addAsyncDataToConsole);

        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static Message lastMsg;
    public static void MsgGetMsgList()
    {
        string conv_id = "287646";

        MsgGetMsgListParam get_message_list_param = new MsgGetMsgListParam();
        get_message_list_param.msg_getmsglist_param_count = 1;
        TIMResult res = TencentIMSDK.MsgGetMsgList(conv_id, TIMConvType.kTIMConv_C2C, get_message_list_param, (int code, string desc, string json_param, string user_data) =>
        {
            List<Message> messages = JsonConvert.DeserializeObject<List<Message>>(json_param);
            if (messages.Count > 0)
            {
                lastMsg = messages[messages.Count - 1];
                Utils.Log("有lastMsg");
            }
            addAsyncDataToConsole(code, desc, json_param, user_data);
        });
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);

    }
    public static void MsgGetMoreMsgList()
    {
        string conv_id = "287646";

        if (lastMsg == null)
        {
            Utils.Log("没有lastMsg");
            return;
        }

        MsgGetMsgListParam get_message_list_param = new MsgGetMsgListParam();

        get_message_list_param.msg_getmsglist_param_count = 1;
        get_message_list_param.msg_getmsglist_param_last_msg = lastMsg;

        TIMResult res = TencentIMSDK.MsgGetMsgList(conv_id, TIMConvType.kTIMConv_C2C, get_message_list_param, (int code, string desc, string json_param, string user_data) =>
        {
            List<Message> messages = JsonConvert.DeserializeObject<List<Message>>(json_param);

            if (messages.Count > 0)
            {
                lastMsg = lastMsg = messages[messages.Count - 1];
            }
            addAsyncDataToConsole(code, desc, json_param, user_data);
            Utils.Log("历史消息列表Count:" + messages.Count.ToString());
        });
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);

    }
    public static void MsgDelete()
    {
        string conv_id = "287646";

        MsgDeleteParam message_delete_param = new MsgDeleteParam();
        message_delete_param.msg_delete_param_msg = new Message(); // 需要删除的消息
        message_delete_param.msg_delete_param_is_remble = true; // 删除漫游消息
        TIMResult res = TencentIMSDK.MsgDelete(conv_id, TIMConvType.kTIMConv_C2C, message_delete_param, addAsyncDataToConsole);

        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgListDelete()
    {
        string conv_id = "287646";

        List<Message> messages_list = new List<Message>();
        messages_list.Add(new Message());
        TIMResult res = TencentIMSDK.MsgListDelete(conv_id, TIMConvType.kTIMConv_C2C, messages_list, addAsyncDataToConsole);

        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgClearHistoryMessage()
    {

        string conv_id = "287646";

        TIMResult res = TencentIMSDK.MsgClearHistoryMessage(conv_id, TIMConvType.kTIMConv_C2C, addAsyncDataToConsole);

        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgSetC2CReceiveMessageOpt()
    {
        string user_id = "287646";
        List<string> user_id_list = new List<string>();
        user_id_list.Add(user_id);
        TIMResult res = TencentIMSDK.MsgSetC2CReceiveMessageOpt(user_id_list, TIMReceiveMessageOpt.kTIMRecvMsgOpt_Receive, addAsyncDataToConsole);

        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgGetC2CReceiveMessageOpt()
    {
        string user_id = "287646";
        List<string> user_id_list = new List<string>();
        user_id_list.Add(user_id);
        TIMResult res = TencentIMSDK.MsgGetC2CReceiveMessageOpt(user_id_list, addAsyncDataToConsole);

        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgSetGroupReceiveMessageOpt()
    {
        string group_id = "im_discuss_TBcYzRWnAp6dmiNT";

        TIMResult res = TencentIMSDK.MsgSetGroupReceiveMessageOpt(group_id, TIMReceiveMessageOpt.kTIMRecvMsgOpt_Receive, addAsyncDataToConsole);

        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgDownloadElemToPath()
    {
        DownloadElemParam param = new DownloadElemParam();
        param.msg_download_elem_param_type = TIMDownloadType.kTIMDownload_File;
        TIMResult res = TencentIMSDK.MsgDownloadElemToPath(param, Application.dataPath, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgDownloadMergerMessage()
    {
        Message message = new Message();
        TIMResult res = TencentIMSDK.MsgDownloadMergerMessage(message, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgBatchSend()
    {
        MsgBatchSendParam param = new MsgBatchSendParam();
        string user_id = "287646";
        List<string> userids = new List<string>();

        userids.Add(user_id);
        Message message = new Message();
        Elem elem = new Elem();
        elem.elem_type = TIMElemType.kTIMElem_Text;
        elem.text_elem_content = "批量发";
        List<Elem> elem_list = new List<Elem>();
        elem_list.Add(elem);
        message.message_elem_array = elem_list;
        param.msg_batch_send_param_identifier_array = userids;
        param.msg_batch_send_param_msg = message;

        TIMResult res = TencentIMSDK.MsgBatchSend(param, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgSearchLocalMessages()
    {
        MessageSearchParam param = new MessageSearchParam();
        List<string> keyword_list = new List<string>();
        keyword_list.Add("批量发");
        keyword_list.Add("1");
        param.msg_search_param_conv_id = "287646";
        param.msg_search_param_conv_type = TIMConvType.kTIMConv_C2C;
        param.msg_search_param_keyword_array = keyword_list;
        param.msg_search_param_keyword_list_match_type = TIMKeywordListMatchType.TIMKeywordListMatchType_Or;
        TIMResult res = TencentIMSDK.MsgSearchLocalMessages(param, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void MsgSetLocalCustomData()
    {
        Message param = new Message(); // 这个message可以是业务的其他message实例
        param.message_custom_int = 1024;
        param.message_custom_str = "hello";
        TIMResult res = TencentIMSDK.MsgSetLocalCustomData(param, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void GroupCreate()
    {
        CreateGroupParam param = new CreateGroupParam(); // 这个message可以是业务的其他message实例
        param.create_group_param_group_id = "test_unity_create_av_1";
        param.create_group_param_group_name = "test_unity_create_name";
        param.create_group_param_group_type = TIMGroupType.kTIMGroup_AVChatRoom;
        param.create_group_param_add_option = TIMGroupAddOption.kTIMGroupAddOpt_Any;
        TIMResult res = TencentIMSDK.GroupCreate(param, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }
    public static void GroupDelete()
    {
        string group_id = "test_unity_create";
        TIMResult res = TencentIMSDK.GroupDelete(group_id, addAsyncDataToConsole);
        Utils.Log(((int)res).ToString());
        addDataToConsole(res);
    }

    public static void SetConfig()
    {
        SetConfig config = new SetConfig();
        config.set_config_log_level = TIMLogLevel.kTIMLog_Test;
        TencentIMSDK.SetConfig(config, addAsyncDataToConsole);
    }
    public static void Uninit()
    {
        TencentIMSDK.Uninit();
        Utils.Log("uninit success");
    }
    public static void GetSDKVersion()
    {
        string version = TencentIMSDK.GetSDKVersion();
        Utils.Log("version " + version);
        addStringDataToConsole(version);
    }

    public static void GetServerTime()
    {
        long time = TencentIMSDK.GetServerTime();
        Utils.Log(time.ToString());
        addStringDataToConsole(time.ToString());
    }
    public static void GroupJoin()
    {
        TIMResult res = TencentIMSDK.GroupJoin("test_unity_create_av_1", "hello", addAsyncDataToConsole);
        addDataToConsole(res);
    }
    public static void GroupModifyMemberInfo()
    {
        GroupModifyMemberInfoParam param = new GroupModifyMemberInfoParam();
        param.group_modify_member_info_group_id = "test_unity_create_av";
        param.group_modify_member_info_modify_flag = TIMGroupMemberModifyInfoFlag.kTIMGroupMemberModifyFlag_MemberRole;
        param.group_modify_member_info_identifier = "287646";
        param.group_modify_member_info_member_role = TIMGroupMemberRole.kTIMMemberRole_Admin;
        TIMResult res = TencentIMSDK.GroupModifyMemberInfo(param, addAsyncDataToConsole);
        addDataToConsole(res);
    }

    public static void ProfileModifySelfUserProfile()
    {
        UserProfileItem param = new UserProfileItem();
        param.user_profile_item_level = 10;
        TIMResult res = TencentIMSDK.ProfileModifySelfUserProfile(param, addAsyncDataToConsole);
        addDataToConsole(res);
    }


    public static void FriendshipModifyFriendProfile()
    {
        FriendshipModifyFriendProfileParam param = new FriendshipModifyFriendProfileParam();
        param.friendship_modify_friend_profile_param_identifier = "287646";
        FriendProfileItem item = new FriendProfileItem();
        List<FriendProfileCustemStringInfo> list = new List<FriendProfileCustemStringInfo>();
        FriendProfileCustemStringInfo info = new FriendProfileCustemStringInfo();
        info.friend_profile_custom_string_info_key = "Tag_SNS_Custom_ATime";
        info.friend_profile_custom_string_info_value = "2021.12.21";
        list.Add(info);
        item.friend_profile_item_custom_string_array = list;
        param.friendship_modify_friend_profile_param_item = item;
        TIMResult res = TencentIMSDK.FriendshipModifyFriendProfile(param, addAsyncDataToConsole);
        addDataToConsole(res);
    }

    public static void FriendshipGetFriendsInfo()
    {
        List<string> json_get_friends_info_param = new List<string>();
        json_get_friends_info_param.Add("287646");

        TencentIMSDK.FriendshipGetFriendsInfo(json_get_friends_info_param, addAsyncDataToConsole);
    }

    public static void FriendshipAddToBlackList()
    {
        List<string> blacklist = new List<string>();
        blacklist.Add("287646");
        TIMResult res = TencentIMSDK.FriendshipAddToBlackList(blacklist, addAsyncDataToConsole);
        addDataToConsole(res);
    }

    void OnGUI()
    {

        if (GUI.Button(new Rect(12, 368, 100, 30), "Clean Console"))
        {
            data = "";
        }


        renderGame();


    }
}
