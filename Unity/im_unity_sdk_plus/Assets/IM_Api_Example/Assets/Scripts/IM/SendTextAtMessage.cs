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
public class SendTextAtMessage : MonoBehaviour
{
  string[] Labels = new string[] { "MessageLabel", "SelectGroupLabel", "SelectGroupMemberLabel", "SelectPriorityLabel", "IsOnlineLabel", "IsUnreadLabel", "needReceiptLabel" };
  public Text Header;
  public InputField Input;
  public Dropdown SelectedGroup;
  public Dropdown SelectedPriority;
  public Toggle IsOnline;
  public Toggle IsUnread;
  public Toggle Receipt;
  public Text Result;
  public Button Submit;
  public Button Copy;
  public List<string> UserList = new List<string>();
  public HashSet<string> SelectedUser = new HashSet<string>();
  private List<string> GroupList;
  private List<string> FriendList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    GroupGetJoinedGroupListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Input = GameObject.Find("Message").GetComponent<InputField>();
    SelectedGroup = GameObject.Find("Group").GetComponent<Dropdown>();
    SelectedGroup.onValueChanged.AddListener(delegate
    {
      GroupDropdownValueChanged(SelectedGroup);
    });
    SelectedPriority = GameObject.Find("Priority").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMMsgPriority)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedPriority.options.Add(option);
    }
    IsOnline = GameObject.Find("Online").GetComponent<Toggle>();
    IsUnread = GameObject.Find("Unread").GetComponent<Toggle>();
    Receipt = GameObject.Find("Receipt").GetComponent<Toggle>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(SendTextAtMessageSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void GroupDropdownValueChanged(Dropdown change)
  {
    GroupGetMemberInfoListSDK();
  }

  void ToggleValueChanged(Toggle change)
  {
    string userID = change.GetComponentInChildren<Text>().text.Split(':')[1];
    if (change.isOn)
    {
      SelectedUser.Add(userID);
    }
    else
    {
      SelectedUser.Remove(userID);
    }
  }

  void GenerateToggle()
  {
    var Parent = GameObject.Find("ToggleContent");
    foreach (Transform child in Parent.transform)
    {
      GameObject.Destroy(child.gameObject);
    }
    var Toggler = GameObject.Find("Toggler").GetComponent<Toggle>();
    foreach (string user_id in UserList)
    {
      var obj = Instantiate(Toggler, Parent.transform);
      obj.GetComponentInChildren<Text>().text = "userID:" + user_id;
      obj.isOn = false;
      obj.onValueChanged.AddListener(delegate
    {
      ToggleValueChanged(obj);
    });
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
      foreach (GroupBaseInfo item in List)
      {
        print(item.group_base_info_group_id);
        GroupList.Add(item.group_base_info_group_id);
        var option = new Dropdown.OptionData();
        option.text = item.group_base_info_group_id;
        SelectedGroup.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedGroup.captionText.text = List[SelectedGroup.value].group_base_info_group_id;
        GroupGetMemberInfoListSDK();
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupListFailed"));
    }
  }

  void GroupGetJoinedGroupListSDK()
  {
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(Utils.addAsyncStringDataToScreen(GetGroupList));
    print($"GroupGetJoinedGroupListSDK {res}");
  }

  void GroupGetMemberInfoListSDK()
  {
    if (GroupList.Count < 1) return;
    string group_id = GroupList[SelectedGroup.value];
    GroupGetMemberInfoListParam param = new GroupGetMemberInfoListParam
    {
      group_get_members_info_list_param_group_id = group_id
    };
    TIMResult res = TencentIMSDK.GroupGetMemberInfoList(param, Utils.addAsyncStringDataToScreen(GetGroupMemberList));
    print($"GroupGetMemberInfoListSDK {res}");
  }

  void GetGroupMemberList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      List<GroupMemberInfo> List = Utils.FromJson<GroupGetMemberInfoListResult>(text).group_get_memeber_info_list_result_info_array;
      UserList = new List<string>();
      SelectedUser = new HashSet<string>();
      foreach (GroupMemberInfo item in List)
      {
        print(item.group_member_info_identifier);
        UserList.Add(item.group_member_info_identifier);
      }
      GenerateToggle();
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupMemberListFailed"));
    }
  }

  void SendTextAtMessageSDK()
  {
    List<string> user_list = new List<string>(SelectedUser);
    var message = new Message
    {
      message_conv_type = TIMConvType.kTIMConv_Group,
      message_cloud_custom_str = "unity local text at data",
      message_elem_array = new List<Elem>{new Elem
      {
        elem_type = TIMElemType.kTIMElem_Text,
        text_elem_content = Input.text
      }},
      message_need_read_receipt = Receipt.isOn,
      message_priority = (TIMMsgPriority)SelectedPriority.value,
      message_is_excluded_from_unread_count = IsUnread.isOn,
      message_is_online_msg = IsOnline.isOn,
      message_group_at_user_array = user_list
    };
    StringBuilder messageId = new StringBuilder(128);
    print(GroupList[SelectedGroup.value]);
    message.message_conv_id = GroupList[SelectedGroup.value];
    message.message_conv_type = TIMConvType.kTIMConv_Group;
    TIMResult res = TencentIMSDK.MsgSendMessage(GroupList[SelectedGroup.value], TIMConvType.kTIMConv_Group, message, messageId, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
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