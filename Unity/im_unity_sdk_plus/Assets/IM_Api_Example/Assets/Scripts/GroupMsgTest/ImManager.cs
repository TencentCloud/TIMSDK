using System.Collections.Generic;
using System.Text;
using UnityEngine;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;



public class ImManager : MonoBehaviourSingleton<ImManager>
{
    private MyImConfig imConfig;

    public void StartConnectIM(MyImConfig m_imConfig)
    {
        imConfig = m_imConfig;

        // Step 1
        InitSdk(m_imConfig);
        // Invoke(nameof(LoginImServer), 1f);
        // // Invoke(nameof(CreateGroup), 1f);
        // Invoke(nameof(JoinGroup), 1f);
        // UIManager.Instance.Close("QrLogin");
    }

    private int InitSdk(MyImConfig m_imConfig)
    {
        imConfig = m_imConfig;

        var sdkappid = imConfig.SdkAppId.ToString();

        SdkConfig sdkConfig = new SdkConfig
        {
            sdk_config_config_file_path = Application.persistentDataPath + "/TIM-Config",
            sdk_config_log_file_path = Application.persistentDataPath + "/TIM-Log"
        };

        TIMResult res = TencentIMSDK.Init(long.Parse(sdkappid), sdkConfig);

        TencentIMSDK.AddRecvNewMsgCallback(RecvNewMsgCallback);

        // Step 2
        LoginImServer();

        return (int) res;
    }

    private int LoginImServer()
    {
        if (imConfig == null)
        {
            Debug.Log("Set IM config first.");
            return 1;
        }

        var userId = imConfig.UserId;
        var userSig = imConfig.UserSig;

        TIMResult res = TencentIMSDK.Login(userId, userSig, AsyncLoginCallback);

        return (int)res;
    }


    private void AsyncLoginCallback(int code, string desc, string json_param, string user_data)
    {
        Debug.Log(user_data + "Login return: " + "code: " + code.ToString() + " desc:" + desc);

        // Step 3
        CreateGroup();
    }

    private void CreateGroup()
    {
        var groupID = imConfig.GroupId;

        CreateGroupParam param = new CreateGroupParam
        {
            create_group_param_group_id = groupID,
            create_group_param_group_name = groupID,
            create_group_param_group_type = TIMGroupType.kTIMGroup_ChatRoom,
            create_group_param_add_option = TIMGroupAddOption.kTIMGroupAddOpt_Any,
            create_group_param_notification = "create_group_param_notification",
            create_group_param_introduction = "create_group_param_introduction",
            create_group_param_face_url = "https://yq.sukeni.com/Logo.jpg"
        };

        TIMResult res = TencentIMSDK.GroupCreate(param, AsyncCreateGroupCallback);
    }

    private void AsyncCreateGroupCallback(int code, string desc, string json_param, string user_data)
    {
        Debug.Log(user_data + "Create Group return code: " + code.ToString() + " desc:" + desc);

        // Step 4
        JoinGroup();
    }

    private void JoinGroup()
    {
        var group_id = imConfig.GroupId;

        TIMResult res = TencentIMSDK.GroupJoin(group_id, "首次加入", AsyncJoinGroupCallback);
    }

    private void AsyncJoinGroupCallback(int code, string desc, string json_param, string user_data)
    {
        Debug.Log(user_data + "Join Group return code: " + code.ToString() + " desc:" + desc);
    }

    public void MsgSendGroupMessage(string sendMsg)
    {
        if (imConfig == null)
        {
            Debug.Log("Set IM config first.");
            return;
        }

        string conv_id = imConfig.GroupId;
        // Debug.Log($"{imConfig.UserId} Send Message {chatInfo.Text} to Group ID: {conv_id}");
        var message = new Message
        {
            message_conv_id = conv_id,
            message_conv_type = TIMConvType.kTIMConv_Group,
            message_cloud_custom_str = "unity local custom data",
            message_elem_array = new List<Elem>
            {
                new Elem
                {
                    elem_type = TIMElemType.kTIMElem_Text,
                    text_elem_content = sendMsg
                }
            },
            message_need_read_receipt = false,
        };
        StringBuilder messageId = new StringBuilder(128);

        TIMResult res = TencentIMSDK.MsgSendMessage(conv_id, TIMConvType.kTIMConv_Group, message, messageId, AsyncMsgSendCallback);
        Debug.Log(((int) res).ToString());
    }

    private static void RecvNewMsgCallback(List<Message> message, string user_data)
    {
        Debug.Log("ChatSystem RecvNewMsgCallback " + message);

        foreach (var msg in message)
        {
            var conv_id = msg.message_conv_id;
            var sendMsg = msg.message_elem_array[0].text_elem_content;
            var clientTime = msg.message_client_time;

            long.TryParse(msg.message_sender, out var senderPid);

            // foreach (var playerInfo in GameManager.Instance.clientModel.PlayerInfos.Values)
            // {
            //     if (senderPid != playerInfo.Pid) continue;
            //
            //     var chatInfo = new ChatInfo(playerInfo.NickName, "", sendMsg, false);
            //     GameEventManager.TriggerEvent(EventID.PlayerChat, chatInfo);
            //     break;
            // }

            Debug.Log($"Receive {sendMsg} from {senderPid}");
        }
    }

    public void GroupModifyMemberName(string playerName)
    {
        GroupModifyMemberInfoParam param = new GroupModifyMemberInfoParam();
        param.group_modify_member_info_group_id = imConfig.GroupId;
        param.group_modify_member_info_modify_flag = TIMGroupMemberModifyInfoFlag.kTIMGroupMemberModifyFlag_MemberRole;
        param.group_modify_member_info_identifier = imConfig.UserId;
        param.group_modify_member_info_name_card = playerName;
        TIMResult res = TencentIMSDK.GroupModifyMemberInfo(param, AsyncMsgSendCallback);
    }


    private void AsyncMsgSendCallback(int code, string desc, string json_param, string user_data)
    {
        Debug.Log(user_data + "MsgSend return code: " + code.ToString() + " desc:" + desc + " json_param: " + json_param + " ");
    }

    void OnDestroy()
    {
        TencentIMSDK.Uninit();
    }
}