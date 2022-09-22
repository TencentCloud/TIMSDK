using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using UnityEngine.SceneManagement;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System;
using com.tencent.im.unity.demo.utils;
using System.Collections;
using System.Collections.Generic;
using EasyUI.Toast;
public class GroupSearchGroupMembers : MonoBehaviour
{
  public List<FriendGroupInfo> GroupList = new List<FriendGroupInfo>();
  public HashSet<string> SelectedGroups = new HashSet<string>();
  public HashSet<string> OriSelectedFriends = new HashSet<string>();
  public InputField Input;
  public Toggle IsSearchUserId;
  public Toggle IsSearchNickName;
  public Toggle IsSearchRemark;
  public Toggle IsSearchNameCard;
  public Text Header;
  public Text Result;
  public Button Submit;
  public Button Copy;
  string[] Labels = new string[] { "SelectGroupLabel", "KeywordLabel", "KeywordPlaceHolder", "IsSearchUserIdLabel", "IsSearchNickNameLabel", "IsSearchRemarkLabel", "IsSearchNameCardLabel" };
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Input = GameObject.Find("InputField").GetComponent<InputField>();
    IsSearchUserId = GameObject.Find("IsSearchUserId").GetComponent<Toggle>();
    IsSearchNickName = GameObject.Find("IsSearchNickName").GetComponent<Toggle>();
    IsSearchRemark = GameObject.Find("IsSearchRemark").GetComponent<Toggle>();
    IsSearchNameCard = GameObject.Find("IsSearchNameCard").GetComponent<Toggle>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GroupSearchGroupMembersSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    GetGroup();
  }

  void ToggleValueChanged(Toggle change)
  {
    string groupId = change.GetComponentInChildren<Text>().text.Split(':')[1];
    if (change.isOn)
    {
      SelectedGroups.Add(groupId);
    }
    else
    {
      SelectedGroups.Remove(groupId);
    }
  }

  void GenerateToggle(List<GroupBaseInfo> GroupList)
  {
    var Parent = GameObject.Find("ToggleContent");
    foreach (Transform child in Parent.transform)
    {
      GameObject.Destroy(child.gameObject);
    }
    var Toggler = GameObject.Find("Toggler").GetComponent<Toggle>();
    foreach (GroupBaseInfo group in GroupList)
    {
      var group_id = group.group_base_info_group_id;
      var obj = Instantiate(Toggler, Parent.transform);
      obj.GetComponentInChildren<Text>().text = "groupId:" + group_id;
      obj.isOn = false;
      obj.onValueChanged.AddListener(delegate
    {
      ToggleValueChanged(obj);
    });
    }
  }

  void SetGroupList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      print(text);
      var GroupList = Utils.FromJson<List<GroupBaseInfo>>(text);
      GenerateToggle(GroupList);
    }
    catch (Exception ex)
    {
      print(ex);
      Toast.Show(Utils.t("getGroupListFailed"));
    }
  }
  public void GetGroup()
  {
    var cb = Utils.addAsyncStringDataToScreen(SetGroupList);
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(cb);
  }

  public void GroupSearchGroupMembersSDK()
  {
    var fieldList = new List<TIMGroupMemberSearchFieldKey>();
    if (IsSearchUserId.isOn)
    {
      fieldList.Add(TIMGroupMemberSearchFieldKey.kTIMGroupMemberSearchFieldKey_Identifier);
    }
    if (IsSearchNickName.isOn)
    {
      fieldList.Add(TIMGroupMemberSearchFieldKey.kTIMGroupMemberSearchFieldKey_NikeName);
    }
    if (IsSearchRemark.isOn)
    {
      fieldList.Add(TIMGroupMemberSearchFieldKey.kTIMGroupMemberSearchFieldKey_Remark);
    }
    if (IsSearchNameCard.isOn)
    {
      fieldList.Add(TIMGroupMemberSearchFieldKey.kTIMGroupMemberSearchFieldKey_NameCard);
    }
    var param = new GroupMemberSearchParam
    {
      group_search_member_params_groupid_list = new List<string>(SelectedGroups),
      group_search_member_params_keyword_list = new List<string>(Input.text.Split(',')),
      group_search_member_params_field_list = fieldList
    };
    TIMResult res = TencentIMSDK.GroupSearchGroupMembers(param, Utils.addAsyncStringDataToScreen(GetResult));
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