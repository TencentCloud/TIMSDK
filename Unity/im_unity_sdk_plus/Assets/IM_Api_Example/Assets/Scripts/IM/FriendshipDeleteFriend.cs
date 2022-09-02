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
public class FriendshipDeleteFriend : MonoBehaviour
{
  string[] Labels = new string[] { "SelectFriendLabel", "SelectFriendTypeLabel" };
  public Text Header;
  public Dropdown SelectedFriend;
  public Dropdown SelectedFriendType;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> FriendList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    FriendshipGetFriendProfileListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedFriend = GameObject.Find("Friend").GetComponent<Dropdown>();
    SelectedFriendType = GameObject.Find("FriendType").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMFriendType)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedFriendType.options.Add(option);
    }
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(FriendshipDeleteFriendSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void GetFriendList(params object[] parameters)
  {
    try
    {
      FriendList = new List<string>();
      SelectedFriend.ClearOptions();
      string text = (string)parameters[1];
      List<FriendProfile> List = Utils.FromJson<List<FriendProfile>>(text);
      foreach (FriendProfile item in List)
      {
        print(item.friend_profile_identifier);
        FriendList.Add(item.friend_profile_identifier);
        var option = new Dropdown.OptionData();
        option.text = item.friend_profile_identifier;
        SelectedFriend.options.Add(option);
      }
      SelectedFriend.value = 0;
      if (List.Count > 0)
      {
        SelectedFriend.captionText.text = List[0].friend_profile_identifier;
      }
      else
      {
        SelectedFriend.captionText.text = "";
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getFriendListFailed"));
    }
  }

  void FriendshipGetFriendProfileListSDK()
  {
    TIMResult res = TencentIMSDK.FriendshipGetFriendProfileList(Utils.addAsyncStringDataToScreen(GetFriendList));
    print($"FriendshipGetFriendProfileListSDK {res}");
  }

  void FriendshipDeleteFriendSDK()
  {
    if (FriendList.Count < 1)
    {
      return;
    }
    print(FriendList[SelectedFriend.value]);
    var param = new FriendshipDeleteFriendParam
    {
      friendship_delete_friend_param_friend_type = (TIMFriendType)SelectedFriendType.value,
      friendship_delete_friend_param_identifier_array = new List<string>{
        FriendList[SelectedFriend.value]
      }
    };
    TIMResult res = TencentIMSDK.FriendshipDeleteFriend(param, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GetResult(params object[] parameters)
  {
    FriendshipGetFriendProfileListSDK();
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