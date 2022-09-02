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
public class FriendshipModifyFriendGroup : MonoBehaviour
{
  public List<FriendGroupInfo> FriendGroupList = new List<FriendGroupInfo>();
  public List<FriendProfile> FriendList = new List<FriendProfile>();
  public HashSet<string> SelectedFriends = new HashSet<string>();
  public HashSet<string> OriSelectedFriends = new HashSet<string>();
  public Dropdown SelectedGroup;
  public InputField Input;
  public Text Header;
  public Text Result;
  public Button Submit;
  public Button Copy;
  string[] Labels = new string[] { "SelectFriendGroupNameLabel", "FriendGroupNameLabel", "SelectFriendLabel" };
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Input = GameObject.Find("InputField").GetComponent<InputField>();
    SelectedGroup = GameObject.Find("Group").GetComponent<Dropdown>();
    SelectedGroup.onValueChanged.AddListener(delegate
    {
      GroupDropdownValueChanged(SelectedGroup);
    });
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(FriendshipDeleteFriendGroupSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    GetAllFriend();
    GetAllFriendGroup();
  }

  void GroupDropdownValueChanged(Dropdown change)
  {
    if (FriendList.Count < 1 || FriendGroupList.Count < 1) return;
    OriSelectedFriends = new HashSet<string>();
    SelectedFriends = new HashSet<string>();
    foreach (var friend in FriendGroupList[SelectedGroup.value].friend_group_info_identifier_array)
    {
      OriSelectedFriends.Add(friend);
    }
    GenerateToggle();
  }

  void ToggleValueChanged(Toggle change)
  {
    string groupName = change.GetComponentInChildren<Text>().text.Split(':')[1];
    if (change.isOn)
    {
      SelectedFriends.Add(groupName);
    }
    else
    {
      SelectedFriends.Remove(groupName);
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
    foreach (FriendProfile friend in FriendList)
    {
      var friend_id = friend.friend_profile_identifier;
      var obj = Instantiate(Toggler, Parent.transform);
      obj.GetComponentInChildren<Text>().text = "friendId:" + friend_id;
      if (OriSelectedFriends.Contains(friend_id))
      {
        obj.isOn = true;
        SelectedFriends.Add(friend_id);
      }
      else
      {
        obj.isOn = false;
      }
      obj.onValueChanged.AddListener(delegate
    {
      ToggleValueChanged(obj);
    });
    }
  }

  void SetFriendList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      print(text);
      FriendList = Utils.FromJson<List<FriendProfile>>(text);
      GroupDropdownValueChanged(SelectedGroup);
    }
    catch (Exception ex)
    {
      print(ex);
      Toast.Show(Utils.t("getFriendListFailed"));
    }
  }

  void SetGroupNameList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      print(text);
      SelectedGroup.ClearOptions();
      FriendGroupList = Utils.FromJson<List<FriendGroupInfo>>(text);
      foreach (FriendGroupInfo item in FriendGroupList)
      {
        print(item.friend_group_info_name);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.friend_group_info_name;
        SelectedGroup.options.Add(option);
      }
      if (FriendGroupList.Count > 0)
      {
        SelectedGroup.captionText.text = FriendGroupList[SelectedGroup.value].friend_group_info_name;
        GroupDropdownValueChanged(SelectedGroup);
      }
    }
    catch (Exception ex)
    {
      print(ex);
      Toast.Show(Utils.t("getFriendGroupListFailed"));
    }
  }

  public void GetAllFriendGroup()
  {
    var cb = Utils.addAsyncStringDataToScreen(SetGroupNameList);
    TIMResult res = TencentIMSDK.FriendshipGetFriendGroupList(new List<string>(), cb);
  }

  public void GetAllFriend()
  {
    var cb = Utils.addAsyncStringDataToScreen(SetFriendList);
    TIMResult res = TencentIMSDK.FriendshipGetFriendProfileList(cb);
  }

  public void FriendshipDeleteFriendGroupSDK()
  {
    var del = new List<string>();
    var add = new List<string>();
    foreach (var selected in SelectedFriends)
    {
      if (!OriSelectedFriends.Contains(selected))
      {
        add.Add(selected);
        print("add " + selected);
      }
    }
    foreach (var selected in OriSelectedFriends)
    {
      if (!SelectedFriends.Contains(selected))
      {
        del.Add(selected);
        print("del " + selected);
      }
    }
    var param = new FriendshipModifyFriendGroupParam
    {
      friendship_modify_friend_group_param_name = FriendGroupList[SelectedGroup.value].friend_group_info_name,
      friendship_modify_friend_group_param_new_name = Input.text ?? FriendGroupList[SelectedGroup.value].friend_group_info_name,
      friendship_modify_friend_group_param_delete_identifier_array = del,
      friendship_modify_friend_group_param_add_identifier_array = add
    };
    TIMResult res = TencentIMSDK.FriendshipModifyFriendGroup(param, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GetResult(params object[] parameters)
  {
    GetAllFriendGroup();
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