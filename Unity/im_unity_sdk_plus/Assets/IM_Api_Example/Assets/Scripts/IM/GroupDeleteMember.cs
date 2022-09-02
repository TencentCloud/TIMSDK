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
public class GroupDeleteMember : MonoBehaviour
{
  public Text Header;
  public InputField UserId;
  public InputField CustomData;
  public Dropdown SelectedGroup;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> GroupList;
  void Start()
  {
    GameObject.Find("SelectGroupLabel").GetComponent<Text>().text = Utils.t("SelectGroupLabel");
    GroupGetJoinedGroupListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedGroup = GameObject.Find("Dropdown").GetComponent<Dropdown>();
    UserId = GameObject.Find("UserId").GetComponent<InputField>();
    CustomData = GameObject.Find("CustomData").GetComponent<InputField>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(GroupDeleteMemberSDK);
    Copy.onClick.AddListener(CopyText);
    SelectedGroup.interactable = true;
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
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
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.group_base_info_group_id;
        SelectedGroup.options.Add(option);
      }
      SelectedGroup.value = 0;
      if (List.Count > 0)
      {
        SelectedGroup.captionText.text = List[0].group_base_info_group_id;
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

  void GroupDeleteMemberSDK()
  {
    if (GroupList.Count < 1)
    {
      return;
    }
    print(GroupList[SelectedGroup.value]);
    string groupID = GroupList[SelectedGroup.value];
    var param = new GroupDeleteMemberParam
    {
      group_delete_member_param_group_id = groupID,
      group_delete_member_param_identifier_array = new List<string> {
        UserId.text
      },
      group_delete_member_param_user_data = CustomData.text
    };
    TIMResult res = TencentIMSDK.GroupDeleteMember(param, Utils.addAsyncStringDataToScreen(GetResult));
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