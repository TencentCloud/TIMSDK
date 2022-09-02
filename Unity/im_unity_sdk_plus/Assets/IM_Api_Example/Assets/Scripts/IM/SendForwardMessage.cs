using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System;
using com.tencent.im.unity.demo.utils;
using EasyUI.Toast;
using System.Collections;
using System.Text;
using System.Collections.Generic;
public class SendForwardMessage : MonoBehaviour
{
  string[] Labels = new string[] { "SelectConvLabel", "SelectMsgLabel", "SelectFriendLabel", "SelectGroupLabel", "SelectPriorityLabel", "IsOnlineLabel", "IsUnreadLabel", "needReceiptLabel" };
  public Text Header;
  public Dropdown SelectedConv;
  public Dropdown SelectedMsg;
  public Dropdown SelectedFriend;
  public Dropdown SelectedGroup;
  public Dropdown SelectedPriority;
  public Toggle IsOnline;
  public Toggle IsUnread;
  public Toggle Receipt;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> GroupList;
  private List<string> FriendList;
  private List<ConvInfo> ConvList;
  private List<Message> MsgList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    GroupGetJoinedGroupListSDK();
    FriendshipGetFriendProfileListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedConv = GameObject.Find("ConvDropdown").GetComponent<Dropdown>();
    SelectedMsg = GameObject.Find("MsgDropdown").GetComponent<Dropdown>();
    SelectedConv.interactable = true;
    SelectedConv.onValueChanged.AddListener(delegate
    {
      ConvDropdownValueChanged(SelectedConv);
    });
    SelectedFriend = GameObject.Find("Friend").GetComponent<Dropdown>();
    SelectedGroup = GameObject.Find("Group").GetComponent<Dropdown>();
    SelectedPriority = GameObject.Find("Priority").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMMsgPriority)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedPriority.options.Add(option);
    }
    SelectedGroup.onValueChanged.AddListener(delegate
    {
      GroupDropdownValueChanged(SelectedGroup);
    });
    SelectedFriend.onValueChanged.AddListener(delegate
    {
      FriendDropdownValueChanged(SelectedFriend);
    });
    IsOnline = GameObject.Find("Online").GetComponent<Toggle>();
    IsUnread = GameObject.Find("Unread").GetComponent<Toggle>();
    Receipt = GameObject.Find("Receipt").GetComponent<Toggle>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(SendForwardMessageSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    ConvGetConvListSDK();
  }

  void MsgGetMsgListSDK(string conv_id, TIMConvType conv_type)
  {
    var get_message_list_param = new MsgGetMsgListParam
    {
      msg_getmsglist_param_count = 20
    };
    print(conv_id + conv_type);
    TIMResult res = TencentIMSDK.MsgGetMsgList(conv_id, conv_type, get_message_list_param, Utils.addAsyncStringDataToScreen(GetMsgList));
  }

  void ConvDropdownValueChanged(Dropdown change)
  {
    SelectedMsg.captionText.text = "";
    SelectedMsg.ClearOptions();
    SelectedMsg.value = 0;
    MsgList = new List<Message>();
    if (ConvList.Count > 0)
    {
      string conv_id = ConvList[change.value].conv_id;
      TIMConvType conv_type = ConvList[change.value].conv_type;
      MsgGetMsgListSDK(conv_id, conv_type);
    }
  }

  void GetMsgList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      List<Message> ListRes = Utils.FromJson<List<Message>>(text);
      foreach (Message item in ListRes)
      {
        print(item.message_msg_id);
        MsgList.Add(item);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.message_msg_id;
        SelectedMsg.options.Add(option);
      }
      if (ListRes.Count > 0)
      {
        SelectedMsg.captionText.text = ListRes[SelectedMsg.value].message_msg_id;
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getMsgListFailed"));
    }
  }

  void GetConvList(params object[] parameters)
  {
    try
    {
      ConvList = new List<ConvInfo>();
      SelectedConv.ClearOptions();
      string text = (string)parameters[1];
      List<ConvInfo> List = Utils.FromJson<List<ConvInfo>>(text);
      foreach (ConvInfo item in List)
      {
        print(item.conv_id);
        ConvList.Add(item);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.conv_id;
        SelectedConv.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedConv.captionText.text = List[SelectedConv.value].conv_id;
        ConvDropdownValueChanged(SelectedConv);
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getConvListFailed"));
    }
  }

  void ConvGetConvListSDK()
  {
    TIMResult res = TencentIMSDK.ConvGetConvList(Utils.addAsyncStringDataToScreen(GetConvList));
    print($"ConvGetConvListSDK {res}");
  }
  void GroupDropdownValueChanged(Dropdown change)
  {
    if (change.value > 0)
    {
      SelectedFriend.value = 0;
    }
  }

  void FriendDropdownValueChanged(Dropdown change)
  {
    if (change.value > 0)
    {
      SelectedGroup.value = 0;
    }
  }

  void GetGroupList(params object[] parameters)
  {
    try
    {
      GroupList = new List<string>();
      SelectedGroup.ClearOptions();
      string text = (string)parameters[1];
      List<GroupBaseInfo> List = Utils.FromJson<List<GroupBaseInfo>>(text);
      Dropdown.OptionData option = new Dropdown.OptionData();
      GroupList.Add("");
      option.text = "";
      SelectedGroup.options.Add(option);
      foreach (GroupBaseInfo item in List)
      {
        print(item.group_base_info_group_id);
        GroupList.Add(item.group_base_info_group_id);
        option = new Dropdown.OptionData();
        option.text = item.group_base_info_group_id;
        SelectedGroup.options.Add(option);
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupListFailed"));
    }
  }

  void GetFriendList(params object[] parameters)
  {
    try
    {
      FriendList = new List<string>();
      SelectedFriend.ClearOptions();
      string text = (string)parameters[1];
      List<FriendProfile> List = Utils.FromJson<List<FriendProfile>>(text);
      Dropdown.OptionData option = new Dropdown.OptionData();
      FriendList.Add("");
      option.text = "";
      SelectedFriend.options.Add(option);
      foreach (FriendProfile item in List)
      {
        print(item.friend_profile_identifier);
        FriendList.Add(item.friend_profile_identifier);
        option = new Dropdown.OptionData();
        option.text = item.friend_profile_identifier;
        SelectedFriend.options.Add(option);
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getFriendListFailed"));
    }
  }

  void GroupGetJoinedGroupListSDK()
  {
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(Utils.addAsyncStringDataToScreen(GetGroupList));
    print($"GroupGetJoinedGroupListSDK {res}");
  }

  void FriendshipGetFriendProfileListSDK()
  {
    TIMResult res = TencentIMSDK.FriendshipGetFriendProfileList(Utils.addAsyncStringDataToScreen(GetFriendList));
    print($"FriendshipGetFriendProfileListSDK {res}");
  }

  void SendForwardMessageSDK()
  {
    if (ConvList.Count < 1 || MsgList.Count < 1) return;
    Message targetMsg = MsgList[SelectedMsg.value];
    var message = new Message
    {
      message_conv_type = TIMConvType.kTIMConv_Group,
      message_cloud_custom_str = "unity local forward data",
      message_elem_array = targetMsg.message_elem_array,
      message_need_read_receipt = Receipt.isOn,
      message_priority = (TIMMsgPriority)SelectedPriority.value,
      message_is_excluded_from_unread_count = IsUnread.isOn,
      message_is_online_msg = IsOnline.isOn
    };
    StringBuilder messageId = new StringBuilder(128);
    if (SelectedGroup.value > 0)
    {
      print(GroupList[SelectedGroup.value]);
      message.message_conv_id = GroupList[SelectedGroup.value];
      message.message_conv_type = TIMConvType.kTIMConv_Group;
      TIMResult res = TencentIMSDK.MsgSendMessage(GroupList[SelectedGroup.value], TIMConvType.kTIMConv_Group, message, messageId, Utils.addAsyncStringDataToScreen(GetResult));
      Result.text = Utils.SynchronizeResult(res);
    }
    else if (SelectedFriend.value > 0)
    {
      print(FriendList[SelectedFriend.value]);
      message.message_conv_id = FriendList[SelectedFriend.value];
      message.message_conv_type = TIMConvType.kTIMConv_C2C;
      TIMResult res = TencentIMSDK.MsgSendMessage(FriendList[SelectedFriend.value], TIMConvType.kTIMConv_C2C, message, messageId, Utils.addAsyncStringDataToScreen(GetResult));
      Result.text = Utils.SynchronizeResult(res);
    }
    print(IsOnline.isOn);
    print(IsUnread.isOn);
  }

  void GetResult(params object[] parameters)
  {
    Result.text += (string)parameters[0];
  }

  void CopyText()
  {
    Utils.Copy(Result.text);
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}