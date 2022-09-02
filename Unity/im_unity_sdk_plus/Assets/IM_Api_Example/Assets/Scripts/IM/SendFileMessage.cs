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
public class SendFileMessage : MonoBehaviour
{
  string[] Labels = new string[] {"FileMessageLabel", "SelectFriendLabel", "SelectGroupLabel", "SelectPriorityLabel", "IsOnlineLabel", "IsUnreadLabel"};
  public Text Header;
  public Button PickFileButton;
  public Text PathText;

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
  private string path;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    GroupGetJoinedGroupListSDK();
    FriendshipGetFriendProfileListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    PickFileButton = GameObject.Find("PickFileButton").GetComponent<Button>();
    PickFileButton.onClick.AddListener(OnPickFile);
    PathText = GameObject.Find("Path").GetComponent<Text>();
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
    Submit.onClick.AddListener(SendFileMessageSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  public void OnPickFile()
  {
    Utils.PickFile((string pathStr) => {
      path = pathStr;
      PathText.text = pathStr;
    });
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

  void SendFileMessageSDK()
  {
    var message = new Message
    {
      message_cloud_custom_str = "unity local file data",
      message_elem_array = new List<Elem>{new Elem
      {
        elem_type = TIMElemType.kTIMElem_File,
        file_elem_file_path = path,
      }},
      message_need_read_receipt = false,
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