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
public class FriendshipDeletePendency : MonoBehaviour
{
  public List<FriendAddPendencyInfo> UserList = new List<FriendAddPendencyInfo>();
  public HashSet<string> SelectedUser = new HashSet<string>();
  public Text Header;
  public Text Result;
  public Dropdown SelectedFriendType;
  public Button Submit;
  public Button Copy;

  void Start()
  {
    GameObject.Find("SelectFriendTypeLabel").GetComponent<Text>().text = Utils.t("SelectFriendTypeLabel");
    GameObject.Find("SelectFriendLabel").GetComponent<Text>().text = Utils.t("SelectFriendLabel");
    FriendshipGetPendencyList();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    SelectedFriendType = GameObject.Find("FriendType").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMFriendPendencyType)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedFriendType.options.Add(option);
    }
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(FriendshipDeletePendencySDK);
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
    foreach (FriendAddPendencyInfo user in UserList)
    {
      var obj = Instantiate(Toggler, Parent.transform);
      obj.GetComponentInChildren<Text>().text = "userID:" + user.friend_add_pendency_info_idenitifer;
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
      List<FriendAddPendencyInfo> List = Utils.FromJson<PendencyPage>(text).pendency_page_pendency_info_array;
      UserList.AddRange(List);
      GenerateToggle();
    }
    catch (Exception ex)
    {
      print(ex);
      Toast.Show(Utils.t("getPendencyListFailed"));
    }
  }

  public void FriendshipGetPendencyList()
  {
    var cb = Utils.addAsyncStringDataToScreen(SetUserList);
    FriendshipGetPendencyListParam param = new FriendshipGetPendencyListParam
    {
      friendship_get_pendency_list_param_type = TIMFriendPendencyType.FriendPendencyTypeComeIn
    };
    TIMResult res = TencentIMSDK.FriendshipGetPendencyList(param, cb);
  }

  public void FriendshipDeletePendencySDK()
  {
    List<string> user_list = new List<string>(SelectedUser);
    var param = new FriendshipDeletePendencyParam
    {
      friendship_delete_pendency_param_type = (TIMFriendPendencyType)SelectedFriendType.value,
      friendship_delete_pendency_param_identifier_array = user_list
    };
    TIMResult res = TencentIMSDK.FriendshipDeletePendency(param, Utils.addAsyncStringDataToScreen(GetResult));
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