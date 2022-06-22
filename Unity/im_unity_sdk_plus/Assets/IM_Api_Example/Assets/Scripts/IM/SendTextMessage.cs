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
public class SendTextMessage : MonoBehaviour
{
  public Text Header;

  public InputField Input;
  public Dropdown SelectedFriend;
  public Dropdown SelectedGroup;
  public Dropdown SelectedPriority;
  public Toggle IsOnline;
  public Toggle IsUnread;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> GroupList;
  private List<string> FriendList;
  void Start()
  {
    GroupGetJoinedGroupListSDK();
    FriendshipGetFriendProfileListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Input = GameObject.Find("Message").GetComponent<InputField>();
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
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(SendTextMessageSDK);
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiText;
    }
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
      SelectedGroup.options.Clear();
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
      Toast.Show("获取群组失败，请登陆");
    }
  }

  void GetFriendList(params object[] parameters)
  {
    try
    {
      FriendList = new List<string>();
      SelectedFriend.options.Clear();
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
      Toast.Show("获取好友失败，请登陆");
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

  void SendTextMessageSDK()
  {

    Message message = new Message();
    List<Elem> messageElems = new List<Elem>();
    Elem textMessage = new Elem();
    textMessage.elem_type = TIMElemType.kTIMElem_Text;
    textMessage.text_elem_content = Input.text;
    messageElems.Add(textMessage);
    message.message_elem_array = messageElems;
    message.message_cloud_custom_str = "unity local custom data";
    message.message_need_read_receipt = true;
    message.message_priority = (TIMMsgPriority)SelectedPriority.value;
    StringBuilder messageId = new StringBuilder(128);
    message.message_is_excluded_from_unread_count = IsUnread.isOn;
    message.message_is_online_msg = IsOnline.isOn;
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