using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using UnityEngine.SceneManagement;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System;
using com.tencent.im.unity.demo.utils;

public class FriendshipAddFriend : MonoBehaviour
{
  public Text Header;
  public InputField FriendID;
  public InputField FriendRemark;
  public InputField FriendGroup;
  public InputField FriendAddWord;
  public Dropdown FriendType;
  public Text Result;

  public Button Submit;
  public Button Copy;
  string[] Labels = new string[] { "FriendIDLabel", "FriendRemarkLabel", "FriendGroupLabel", "FriendAddWordLabel", "SelectFriendTypeLabel" };
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    FriendID = GameObject.Find("FriendID").GetComponent<InputField>();
    FriendRemark = GameObject.Find("FriendRemark").GetComponent<InputField>();
    FriendGroup = GameObject.Find("FriendGroup").GetComponent<InputField>();
    FriendAddWord = GameObject.Find("FriendAddWord").GetComponent<InputField>();
    FriendType = GameObject.Find("Dropdown").GetComponent<Dropdown>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(FriendshipAddFriendSDK);
    Copy.onClick.AddListener(CopyText);
    FriendType.interactable = true;
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    foreach (string name in Enum.GetNames(typeof(TIMFriendType)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      FriendType.options.Add(option);
    }
  }

  public void FriendshipAddFriendSDK()
  {
    print(FriendID.text);
    print(FriendRemark.text);
    print(FriendGroup.text);
    print(FriendAddWord.text);
    print(FriendType.value);

    FriendshipAddFriendParam param = new FriendshipAddFriendParam
    {
      friendship_add_friend_param_identifier = FriendID.text,
      friendship_add_friend_param_remark = FriendRemark.text,
      friendship_add_friend_param_group_name = FriendGroup.text,
      friendship_add_friend_param_add_wording = FriendAddWord.text,
      friendship_add_friend_param_friend_type = (TIMFriendType)FriendType.value
    };
    TIMResult res = TencentIMSDK.FriendshipAddFriend(param, Utils.addAsyncStringDataToScreen(GetResult));
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