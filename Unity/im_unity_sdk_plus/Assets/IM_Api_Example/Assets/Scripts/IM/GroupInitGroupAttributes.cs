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
public class GroupInitGroupAttributes : MonoBehaviour
{
  string[] Labels = new string[] { "GroupIDLabel", "GroupCustomKeyLabel", "GroupCustomValueLabel", "CustomKeyPlaceHolder", "CustomValuePlaceHolder" };
  public Text Header;
  public Dropdown SelectedGroup;
  public InputField CustomKey;
  public InputField CustomValue;
  public Text Result;
  public Button Submit;
  public Button Copy;
  List<string> groupIDList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedGroup = GameObject.Find("GroupID").GetComponent<Dropdown>();
    CustomKey = GameObject.Find("CustomKey").GetComponent<InputField>();
    CustomValue = GameObject.Find("CustomValue").GetComponent<InputField>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GroupInitGroupAttributesSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    GroupGetJoinedGroupListSDK();
  }

  void GetGroupList(params object[] parameters)
  {
    try
    {
      groupIDList = new List<string>();
      SelectedGroup.ClearOptions();
      string text = (string)parameters[1];
      List<GroupBaseInfo> List = Utils.FromJson<List<GroupBaseInfo>>(text);
      foreach (GroupBaseInfo item in List)
      {
        print(item.group_base_info_group_id);
        groupIDList.Add(item.group_base_info_group_id);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.group_base_info_group_id;
        SelectedGroup.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedGroup.captionText.text = List[SelectedGroup.value].group_base_info_group_id;
      }
      else
      {
        SelectedGroup.captionText.text = "";
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupListFailed"));
    }
  }

  void GroupGetJoinedGroupListSDK()
  {
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(Utils.addAsyncStringDataToScreen(GetGroupList));
    print($"GroupGetJoinedGroupListSDK {res}");
  }

  void GroupInitGroupAttributesSDK()
  {
    if (groupIDList.Count < 1) return;
    var custom_string_array = new List<GroupAttributes>();
    var keys = CustomKey.text.Split(',');
    var vals = CustomValue.text.Split(',');
    for (int idx = 0; idx < keys.Length; idx++)
    {
      if (!string.IsNullOrEmpty(keys[idx]))
      {
        custom_string_array.Add(new GroupAttributes
        {
          group_atrribute_key = keys[idx],
          group_atrribute_value = idx < vals.Length ? vals[idx] : ""
        });
      }
    }
    TIMResult res = TencentIMSDK.GroupInitGroupAttributes("@TGS#aNMXML5HZ", custom_string_array, Utils.addAsyncNullDataToScreen(GetResult));
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