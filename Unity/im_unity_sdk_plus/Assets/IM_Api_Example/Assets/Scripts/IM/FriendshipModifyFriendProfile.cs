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
public class FriendshipModifyFriendProfile : MonoBehaviour
{
  string[] Labels = new string[] { "SelectFriendLabel", "FriendRemarkLabel", "FriendCustomKeyLabel", "FriendCustomKeyPlaceHolder", "FriendCustomValueLabel" };
  public Text Header;
  public Dropdown SelectedFriend;
  public InputField Remark;
  public InputField CustomKey;
  public InputField CustomValue;
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
    Remark = GameObject.Find("Remark").GetComponent<InputField>();
    CustomKey = GameObject.Find("CustomKey").GetComponent<InputField>();
    CustomValue = GameObject.Find("CustomValue").GetComponent<InputField>();
    SelectedFriend = GameObject.Find("Friend").GetComponent<Dropdown>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(FriendshipModifyFriendProfileSDK);
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
      if (List.Count > 0)
      {
        SelectedFriend.captionText.text = List[SelectedFriend.value].friend_profile_identifier;
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

  void FriendshipModifyFriendProfileSDK()
  {
    var param = new FriendshipModifyFriendProfileParam
    {
      friendship_modify_friend_profile_param_identifier = FriendList[SelectedFriend.value],
      friendship_modify_friend_profile_param_item = new FriendProfileItem
      {
        friend_profile_item_remark = Remark.text
      }
    };
    if (!string.IsNullOrEmpty(CustomKey.text))
    {
      var custom_string_array = new List<FriendProfileCustemStringInfo>();
      var keys = CustomKey.text.Split(',');
      var vals = CustomValue.text.Split(',');
      for (int idx = 0; idx < keys.Length; idx++)
      {
        custom_string_array.Add(new FriendProfileCustemStringInfo
        {
          friend_profile_custom_string_info_key = keys[idx],
          friend_profile_custom_string_info_value = idx < vals.Length ? vals[idx] : ""
        });
      }
      param.friendship_modify_friend_profile_param_item.friend_profile_item_custom_string_array = custom_string_array;
    }
    TIMResult res = TencentIMSDK.FriendshipModifyFriendProfile(param, Utils.addAsyncNullDataToScreen(GetResult));
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