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
public class FriendshipGetFriendGroupList : MonoBehaviour
{
  public List<FriendGroupInfo> UserList = new List<FriendGroupInfo>();
  public HashSet<string> SelectedGroupName = new HashSet<string>();
  public Text Header;
  public Text Result;
  public Button Submit;
  public Button Copy;

  void Start()
  {
    GameObject.Find("SelectFriendGroupNameLabel").GetComponent<Text>().text = Utils.t("SelectFriendGroupNameLabel");
    FriendshipGetFriendProfileList();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(FriendshipGetFriendGroupListSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void ToggleValueChanged(Toggle change)
  {
    string groupName = change.GetComponentInChildren<Text>().text.Split(':')[1];
    if (change.isOn)
    {
      SelectedGroupName.Add(groupName);
    }
    else
    {
      SelectedGroupName.Remove(groupName);
    }
  }

  void GenerateToggle()
  {
    var Parent = GameObject.Find("ToggleContent");
    var Toggler = GameObject.Find("Toggler").GetComponent<Toggle>();
    foreach (FriendGroupInfo user in UserList)
    {
      var obj = Instantiate(Toggler, Parent.transform);
      obj.GetComponentInChildren<Text>().text = "groupName:" + user.friend_group_info_name;
      obj.isOn = false;
      obj.onValueChanged.AddListener(delegate
    {
      ToggleValueChanged(obj);
    });
    }
  }

  void SetGroupNameList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      print(text);
      List<FriendGroupInfo> List = Utils.FromJson<List<FriendGroupInfo>>(text);
      UserList.AddRange(List);
      GenerateToggle();
    }
    catch (Exception ex)
    {
      print(ex);
      Toast.Show(Utils.t("getFriendGroupListFailed"));
    }
  }

  public void FriendshipGetFriendProfileList()
  {
    var cb = Utils.addAsyncStringDataToScreen(SetGroupNameList);
    TIMResult res = TencentIMSDK.FriendshipGetFriendGroupList(new List<string>(), cb);
  }

  public void FriendshipGetFriendGroupListSDK()
  {
    List<string> groupNames = new List<string>(SelectedGroupName);
    TIMResult res = TencentIMSDK.FriendshipGetFriendGroupList(groupNames, Utils.addAsyncStringDataToScreen(GetResult));
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