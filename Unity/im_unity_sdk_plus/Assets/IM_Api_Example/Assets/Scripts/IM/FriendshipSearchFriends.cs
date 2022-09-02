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
public class FriendshipSearchFriends : MonoBehaviour
{
  string[] Labels = new string[] { "KeywordLabel", "FriendSearchFieldLabel" };
  public Text Header;
  public InputField Input;
  public Dropdown FriendSearchField;
  public Text Result;
  public Button Submit;
  public Button Copy;
  public int[] EnumFriendSearchField = (int[])Enum.GetValues(typeof(TIMFriendshipSearchFieldKey));
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Input = GameObject.Find("InputField").GetComponent<InputField>();
    FriendSearchField = GameObject.Find("FriendSearchField").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMFriendshipSearchFieldKey)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      FriendSearchField.options.Add(option);
    }
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(FriendshipSearchFriendsSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }
  void FriendshipSearchFriendsSDK()
  {
    var param = new FriendSearchParam
    {
      friendship_search_param_keyword_list = new List<string>
      {
        Input.text
      },
      friendship_search_param_search_field_list = new List<TIMFriendshipSearchFieldKey>
      {
      (TIMFriendshipSearchFieldKey) EnumFriendSearchField[FriendSearchField.value]
      }
    };
    TIMResult res = TencentIMSDK.FriendshipSearchFriends(param, Utils.addAsyncStringDataToScreen(GetResult));
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