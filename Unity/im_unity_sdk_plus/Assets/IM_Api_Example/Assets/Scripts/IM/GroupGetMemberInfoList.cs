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
using System.Collections.Generic;
public class GroupGetMemberInfoList : MonoBehaviour
{
  public Text Header;
  public Dropdown SelectedGroup;
  public Dropdown SelectedRole;
  public Text LastSeq;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> GroupList;
  public int[] EnumRoleFlag = (int[])Enum.GetValues(typeof(TIMGroupMemberRoleFlag));
  string[] Labels = new string[] { "SelectGroupLabel", "SelectRoleLabel" };
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedGroup = GameObject.Find("Group").GetComponent<Dropdown>();
    SelectedRole = GameObject.Find("Role").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMGroupMemberRoleFlag)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedRole.options.Add(option);
    }
    LastSeq = GameObject.Find("LastSeq").GetComponent<Text>();
    LastSeq.text = "0";
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(GroupGetMemberInfoListSDK);
    Copy.onClick.AddListener(CopyText);
    SelectedGroup.interactable = true;
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    GroupGetGroupListSDK();
  }

  void GetGroupList(params object[] parameters)
  {
    try
    {
      SelectedGroup.ClearOptions();
      GroupList = new List<string>();
      string text = (string)parameters[1];
      List<GroupBaseInfo> List = Utils.FromJson<List<GroupBaseInfo>>(text);
      foreach (GroupBaseInfo item in List)
      {
        GroupList.Add(item.group_base_info_group_id);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.group_base_info_group_id;
        SelectedGroup.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedGroup.captionText.text = List[SelectedGroup.value].group_base_info_group_id;
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupListFailed"));
    }
  }

  void GroupGetGroupListSDK()
  {
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(Utils.addAsyncStringDataToScreen(GetGroupList));
    print($"GroupGetGroupListSDK {res}");
  }

  void GroupGetMemberInfoListSDK()
  {
    if (GroupList.Count < 1) return;
    var param = new GroupGetMemberInfoListParam
    {
      group_get_members_info_list_param_group_id = GroupList[SelectedGroup.value],
      group_get_members_info_list_param_option = new GroupMemberGetInfoOption
      {
        group_member_get_info_option_role_flag = (TIMGroupMemberRoleFlag)EnumRoleFlag[SelectedRole.value]
      },
      group_get_members_info_list_param_next_seq = Convert.ToUInt64(LastSeq.text)
    };
    TIMResult res = TencentIMSDK.GroupGetMemberInfoList(param, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GetResult(params object[] parameters)
  {
    Result.text += (string)parameters[0];
    LastSeq.text = Utils.FromJson<GroupGetMemberInfoListResult>((string)parameters[1]).group_get_memeber_info_list_result_next_seq.ToString();
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