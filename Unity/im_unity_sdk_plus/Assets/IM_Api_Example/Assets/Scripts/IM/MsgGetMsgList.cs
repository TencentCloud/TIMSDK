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
public class MsgGetMsgList : MonoBehaviour
{
  public Text Header;

  public Text LastMessageID;
  public Dropdown SelectedFriend;
  public Dropdown SelectedGroup;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> GroupList;
  private List<string> FriendList;
  private Message LastMessage;
  void Start()
  {
    GroupGetJoinedGroupListSDK();
    FriendshipGetFriendProfileListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    LastMessageID = GameObject.Find("LastMessageID").GetComponent<Text>();
    SelectedFriend = GameObject.Find("Friend").GetComponent<Dropdown>();
    SelectedGroup = GameObject.Find("Group").GetComponent<Dropdown>();
    SelectedGroup.onValueChanged.AddListener(delegate
    {
      GroupDropdownValueChanged(SelectedGroup);
    });
    SelectedFriend.onValueChanged.AddListener(delegate
    {
      FriendDropdownValueChanged(SelectedFriend);
    });
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(MsgGetMsgListSDK);
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

  void MsgGetMsgListSDK()
  {
    var get_message_list_param = new MsgGetMsgListParam
    {
      msg_getmsglist_param_count = 20
    };
    if (LastMessage != null)
    {
      get_message_list_param.msg_getmsglist_param_last_msg = LastMessage;
    }
    if (SelectedGroup.value > 0)
    {
      print(GroupList[SelectedGroup.value]);
      TIMResult res = TencentIMSDK.MsgGetMsgList(GroupList[SelectedGroup.value], TIMConvType.kTIMConv_Group, get_message_list_param, Utils.addAsyncStringDataToScreen(GetResult));
      Result.text = Utils.SynchronizeResult(res);
    }
    else if (SelectedFriend.value > 0)
    {
      print(FriendList[SelectedFriend.value]);
      TIMResult res = TencentIMSDK.MsgGetMsgList(FriendList[SelectedFriend.value], TIMConvType.kTIMConv_C2C, get_message_list_param, Utils.addAsyncStringDataToScreen(GetResult));
      Result.text = Utils.SynchronizeResult(res);
    }
  }

  void GetResult(params object[] parameters)
  {
    Result.text += (string)parameters[0];
    List<Message> messages = Utils.FromJson<List<Message>>((string)parameters[1]);
    if (messages.Count > 0)
    {
      LastMessage = messages[messages.Count - 1];
      LastMessageID.text = messages[messages.Count - 1].message_msg_id;
      print("有lastMsg");
    }
    else
    {
      LastMessage = null;
      LastMessageID.text = "";
    }
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