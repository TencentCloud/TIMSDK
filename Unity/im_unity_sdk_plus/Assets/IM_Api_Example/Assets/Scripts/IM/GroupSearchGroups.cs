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
public class GroupSearchGroups : MonoBehaviour
{
  string[] Labels = new string[] { "KeywordLabel", "KeywordPlaceHolder", "SelectGroupSearchFieldLabel" };
  public Text Header;
  public InputField Keyword;
  public Dropdown SelectedSearchField;
  public Text Result;
  public Button Submit;
  public Button Copy;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Keyword = GameObject.Find("Keyword").GetComponent<InputField>();
    SelectedSearchField = GameObject.Find("SelectedSearchField").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMGroupSearchFieldKey)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedSearchField.options.Add(option);
    }
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GroupSearchGroupsSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void GroupSearchGroupsSDK()
  {
    var keywordList = new List<string>(Keyword.text.Split(','));
    var fieldList = new List<TIMGroupSearchFieldKey>
    {
      SelectedSearchField.value == 1 ? TIMGroupSearchFieldKey.kTIMGroupSearchFieldKey_GroupName : TIMGroupSearchFieldKey.kTIMGroupSearchFieldKey_GroupId
    };
    var param = new GroupSearchParam
    {
      group_search_params_keyword_list = keywordList,
      group_search_params_field_list = fieldList
    };
    print(Utils.ToJson(param));
    TIMResult res = TencentIMSDK.GroupSearchGroups(param, Utils.addAsyncStringDataToScreen(GetResult));
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