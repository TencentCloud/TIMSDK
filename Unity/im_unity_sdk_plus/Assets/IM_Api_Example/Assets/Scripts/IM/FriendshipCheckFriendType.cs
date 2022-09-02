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
public class FriendshipCheckFriendType : MonoBehaviour
{
  public List<FriendProfile> UserList = new List<FriendProfile>();
  public HashSet<string> SelectedUser = new HashSet<string>();
  public Text Header;
  public Text Result;
  public Dropdown SelectedFriendType;
  public Button Submit;
  public Button Copy;

  void Start()
  {
    GameObject.Find("SelectUserLabel").GetComponent<Text>().text = Utils.t("SelectUserLabel");
    FriendshipGetFriendProfileList();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    SelectedFriendType = GameObject.Find("FriendType").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMFriendType)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedFriendType.options.Add(option);
    }
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(FriendshipCheckFriendTypeSDK);
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
      Toast.Show(Utils.t("getFriendListFailed"));
    }
  }

  public void FriendshipGetFriendProfileList()
  {
    var Users = UserList;
    var cb = Utils.addAsyncStringDataToScreen(SetUserList);
    TIMResult res = TencentIMSDK.FriendshipGetFriendProfileList(cb);
  }

  public void FriendshipCheckFriendTypeSDK()
  {
    List<string> user_list = new List<string>(SelectedUser);
    var param = new FriendshipCheckFriendTypeParam
    {
      friendship_check_friendtype_param_check_type = (TIMFriendType)SelectedFriendType.value,
      friendship_check_friendtype_param_identifier_array = user_list
    };
    TIMResult res = TencentIMSDK.FriendshipCheckFriendType(param, Utils.addAsyncStringDataToScreen(GetResult));
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