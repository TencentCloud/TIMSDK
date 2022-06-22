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
public class ProfileGetUserProfileList : MonoBehaviour
{
  public List<FriendProfile> UserList = new List<FriendProfile>();
  public HashSet<string> SelectedUser = new HashSet<string>();
  public Text Header;
  public Text Result;

  public Button Submit;
  public Button Copy;

  void Start()
  {
    FriendshipGetFriendProfileList();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(ProfileGetUserProfileListSDK);
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiText;
    }
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
    var Toggler = GameObject.Find("Toggler").GetComponent<Toggle>();
    foreach (FriendProfile user in UserList)
    {
      var obj = Instantiate(Toggler, Parent.transform);
      obj.GetComponentInChildren<Text>().text = "userID:" + user.friend_profile_identifier;
      obj.isOn = false;
      obj.onValueChanged.AddListener(delegate
    {
      ToggleValueChanged(obj);
    });
    }
  }

  void SetUserList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      print(text);
      List<FriendProfile> List = Utils.FromJson<List<FriendProfile>>(text);
      UserList.AddRange(List);
      GenerateToggle();
    }
    catch (Exception ex)
    {
      print(ex);
      Toast.Show("获取好友失败，请登陆");
    }
  }

  public void FriendshipGetFriendProfileList()
  {
    var Users = UserList;
    var cb = Utils.addAsyncStringDataToScreen(SetUserList);
    TIMResult res = TencentIMSDK.FriendshipGetFriendProfileList(cb);
  }

  public void ProfileGetUserProfileListSDK()
  {
    FriendShipGetProfileListParam json_get_user_profile_list_param = new FriendShipGetProfileListParam();
    json_get_user_profile_list_param.friendship_getprofilelist_param_identifier_array = new List<string>(SelectedUser);
    TIMResult res = TencentIMSDK.ProfileGetUserProfileList(json_get_user_profile_list_param, Utils.addAsyncStringDataToScreen(GetResult));
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