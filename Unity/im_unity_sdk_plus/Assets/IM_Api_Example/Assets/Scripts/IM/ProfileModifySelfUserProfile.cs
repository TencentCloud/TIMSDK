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
public class ProfileModifySelfUserProfile : MonoBehaviour
{
  string[] Labels = new string[] { "NicknameLabel", "SelectGenderLabel", "FaceURLLabel", "SignatureLabel", "SelectAddPermissionLabel", "ProfileCustomKeyLabel", "ProfileCustomValueLabel", "CustomKeyPlaceHolder", "CustomValuePlaceHolder" };
  public Text Header;
  public InputField Nickname;
  public InputField FaceURL;
  public InputField Signature;
  public InputField CustomKey;
  public InputField CustomValue;
  public Dropdown Gender;
  public Dropdown AddPermission;
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
    Nickname = GameObject.Find("Nickname").GetComponent<InputField>();
    FaceURL = GameObject.Find("FaceURL").GetComponent<InputField>();
    Signature = GameObject.Find("Signature").GetComponent<InputField>();
    CustomKey = GameObject.Find("CustomKey").GetComponent<InputField>();
    CustomValue = GameObject.Find("CustomValue").GetComponent<InputField>();
    AddPermission = GameObject.Find("AddPermission").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMProfileAddPermission)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      AddPermission.options.Add(option);
    }
    Gender = GameObject.Find("Gender").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMGenderType)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      Gender.options.Add(option);
    }
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(ProfileModifySelfUserProfileSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void ProfileModifySelfUserProfileSDK()
  {
    var custom_string_array = new List<UserProfileCustemStringInfo>();
    var keys = CustomKey.text.Split(',');
    var vals = CustomValue.text.Split(',');
    for (int idx = 0; idx < keys.Length; idx++)
    {
      if (!string.IsNullOrEmpty(keys[idx]))
      {
        custom_string_array.Add(new UserProfileCustemStringInfo
        {
          user_profile_custom_string_info_key = keys[idx],
          user_profile_custom_string_info_value = idx < vals.Length ? vals[idx] : ""
        });
      }
    }
    var param = new UserProfileItem
    {
      user_profile_item_gender = (TIMGenderType)Gender.value,
      user_profile_item_add_permission = (TIMProfileAddPermission)AddPermission.value,
    };
    if (!string.IsNullOrEmpty(Nickname.text))
    {
      param.user_profile_item_nick_name = Nickname.text;
    }
    if (!string.IsNullOrEmpty(FaceURL.text))
    {
      param.user_profile_item_face_url = FaceURL.text;
    }
    if (!string.IsNullOrEmpty(Signature.text))
    {
      param.user_profile_item_self_signature = Signature.text;
    }
    if (custom_string_array.Count > 0)
    {
      param.user_profile_item_custom_string_array = custom_string_array;
    }
    TIMResult res = TencentIMSDK.ProfileModifySelfUserProfile(param, Utils.addAsyncNullDataToScreen(GetResult));
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