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
public class SetSelfStatus : MonoBehaviour
{
  string[] Labels = new string[] { "SelectUserStatusLabel", "CustomStatusLabel" };
  public Text Header;
  public Text UserID;
  public InputField CustomStatus;
  public Dropdown SelectedStatus;
  public Text Result;
  public Button Submit;
  public Button Copy;
  string userID;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    UserID = GameObject.Find("UserID").GetComponent<Text>();
    try
    {
      StringBuilder userId = new StringBuilder(128);
      TencentIMSDK.GetLoginUserID(userId);
      userID = userId.ToString();
      UserID.text = userID;
    }
    catch (Exception e) { }
    CustomStatus = GameObject.Find("CustomStatus").GetComponent<InputField>();
    SelectedStatus = GameObject.Find("SelectedStatus").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMUserStatusType)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedStatus.options.Add(option);
    }
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(SetSelfStatusSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void SetSelfStatusSDK()
  {
    var param = new UserStatus
    {
      user_status_identifier = userID,
      user_status_status_type = (TIMUserStatusType)SelectedStatus.value,
      user_status_custom_status = CustomStatus.text
    };
    TIMResult res = TencentIMSDK.SetSelfStatus(param, Utils.addAsyncStringDataToScreen(GetResult));
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