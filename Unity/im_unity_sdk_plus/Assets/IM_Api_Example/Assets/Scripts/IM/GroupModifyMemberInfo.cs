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
public class GroupModifyMemberInfo : MonoBehaviour
{
  string[] Labels = new string[] { "GroupIDLabel", "SelectGroupMemberLabel", "SelectMessageFlagLabel", "SelectRoleLabel", "ShutupTimeLabel", "GroupNameCardLabel", "MemberCustomKeyLabel", "MemberCustomValueLabel", "CustomKeyPlaceHolder", "CustomValuePlaceHolder" };
  public Text Header;
  public Dropdown SelectedGroup;
  public Dropdown SelectedGroupMember;
  public Dropdown MessageFlag;
  public Dropdown Role;
  public InputField ShutupTime;
  public InputField NameCard;
  public InputField CustomKey;
  public InputField CustomValue;
  public Text Result;
  public Button Submit;
  public Button Copy;
  public int[] EnumRole = (int[])Enum.GetValues(typeof(TIMGroupMemberRole));
  List<string> groupIDList;
  List<string> groupMemberIDList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedGroup = GameObject.Find("Group").GetComponent<Dropdown>();
    SelectedGroup.onValueChanged.AddListener(delegate
    {
      GroupDropdownValueChanged(SelectedGroup);
    });
    SelectedGroupMember = GameObject.Find("GroupMember").GetComponent<Dropdown>();
    MessageFlag = GameObject.Find("MessageFlag").GetComponent<Dropdown>();
    MessageFlag.options.Add(new Dropdown.OptionData
    {
      text = ""
    });
    foreach (string name in Enum.GetNames(typeof(TIMReceiveMessageOpt)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      MessageFlag.options.Add(option);
    }
    Role = GameObject.Find("Role").GetComponent<Dropdown>();
    Role.options.Add(new Dropdown.OptionData
    {
      text = ""
    });
    foreach (string name in Enum.GetNames(typeof(TIMGroupMemberRole)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      Role.options.Add(option);
    }
    NameCard = GameObject.Find("NameCard").GetComponent<InputField>();
    ShutupTime = GameObject.Find("ShutupTime").GetComponent<InputField>();
    CustomKey = GameObject.Find("CustomKey").GetComponent<InputField>();
    CustomValue = GameObject.Find("CustomValue").GetComponent<InputField>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GroupModifyMemberInfoSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    GroupGetJoinedGroupListSDK();
  }

  void GetGroupMemberList(params object[] parameters)
  {
    try
    {
      groupMemberIDList = new List<string>();
      SelectedGroupMember.ClearOptions();
      string text = (string)parameters[1];
      List<GroupMemberInfo> List = Utils.FromJson<GroupGetMemberInfoListResult>(text).group_get_memeber_info_list_result_info_array;
      foreach (GroupMemberInfo item in List)
      {
        print(item.group_member_info_identifier);
        groupMemberIDList.Add(item.group_member_info_identifier);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.group_member_info_identifier;
        SelectedGroupMember.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedGroupMember.captionText.text = List[SelectedGroupMember.value].group_member_info_identifier;
      }
      else
      {
        SelectedGroupMember.captionText.text = "";
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupMemberListFailed"));
    }
  }

  void GroupGetMemberInfoListSDK()
  {
    if (groupIDList.Count < 1) return;
    string group_id = groupIDList[SelectedGroup.value];
    GroupGetMemberInfoListParam param = new GroupGetMemberInfoListParam
    {
      group_get_members_info_list_param_group_id = group_id
    };
    TIMResult res = TencentIMSDK.GroupGetMemberInfoList(param, Utils.addAsyncStringDataToScreen(GetGroupMemberList));
    print($"GroupGetMemberInfoListSDK {res}");
  }

  void GroupDropdownValueChanged(Dropdown change)
  {
    GroupGetMemberInfoListSDK();
  }

  void GetGroupList(params object[] parameters)
  {
    try
    {
      groupIDList = new List<string>();
      SelectedGroup.ClearOptions();
      string text = (string)parameters[1];
      List<GroupBaseInfo> List = Utils.FromJson<List<GroupBaseInfo>>(text);
      foreach (GroupBaseInfo item in List)
      {
        print(item.group_base_info_group_id);
        groupIDList.Add(item.group_base_info_group_id);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.group_base_info_group_id;
        SelectedGroup.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedGroup.captionText.text = List[SelectedGroup.value].group_base_info_group_id;
        GroupGetMemberInfoListSDK();
      }
      else
      {
        SelectedGroup.captionText.text = "";
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

  void GroupModifyMemberInfoSDK()
  {
    if (groupIDList.Count < 1 || groupMemberIDList.Count < 1) return;
    var custom_string_array = new List<GroupMemberInfoCustemString>();
    var keys = CustomKey.text.Split(',');
    var vals = CustomValue.text.Split(',');
    for (int idx = 0; idx < keys.Length; idx++)
    {
      if (!string.IsNullOrEmpty(keys[idx]))
      {
        custom_string_array.Add(new GroupMemberInfoCustemString
        {
          group_member_info_custom_string_info_key = keys[idx],
          group_member_info_custom_string_info_value = idx < vals.Length ? vals[idx] : ""
        });
      }
    }
    var param = new GroupModifyMemberInfoParam
    {
      group_modify_member_info_group_id = groupIDList[SelectedGroup.value],
      group_modify_member_info_identifier = groupMemberIDList[SelectedGroupMember.value],
    };
    var flag = TIMGroupMemberModifyInfoFlag.kTIMGroupMemberModifyFlag_None;
    if (MessageFlag.value > 0)
    {
      param.group_modify_member_info_msg_flag = (TIMReceiveMessageOpt)(MessageFlag.value - 1);
      flag |= TIMGroupMemberModifyInfoFlag.kTIMGroupMemberModifyFlag_MsgFlag;
    }
    if (Role.value > 0)
    {
      param.group_modify_member_info_member_role = (TIMGroupMemberRole)(EnumRole[Role.value - 1]);
      flag |= TIMGroupMemberModifyInfoFlag.kTIMGroupMemberModifyFlag_MemberRole;
    }
    if (!string.IsNullOrEmpty(ShutupTime.text))
    {
      int shutupTime;
      if (!int.TryParse(ShutupTime.text, out shutupTime))
      {
        Debug.LogError("Input ShutupTime is not number!");
        return;
      }
      else if (shutupTime < 0)
      {
        Debug.LogError("Input ShutupTime can't be negative number!");
        return;
      }
      param.group_modify_member_info_shutup_time = (uint)(shutupTime);
      flag |= TIMGroupMemberModifyInfoFlag.kTIMGroupMemberModifyFlag_ShutupTime;
    }
    if (!string.IsNullOrEmpty(NameCard.text))
    {
      param.group_modify_member_info_name_card = NameCard.text;
      flag |= TIMGroupMemberModifyInfoFlag.kTIMGroupMemberModifyFlag_NameCard;
    }
    if (custom_string_array.Count > 0)
    {
      param.group_modify_member_info_custom_info = custom_string_array;
      flag |= TIMGroupMemberModifyInfoFlag.kTIMGroupMemberModifyFlag_Custom;
    }
    param.group_modify_member_info_modify_flag = flag;
    print(Utils.ToJson(param));
    TIMResult res = TencentIMSDK.GroupModifyMemberInfo(param, Utils.addAsyncNullDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
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