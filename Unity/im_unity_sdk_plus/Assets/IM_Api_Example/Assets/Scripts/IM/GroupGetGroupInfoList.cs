using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using UnityEngine.SceneManagement;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System;
using System.Linq;
using com.tencent.im.unity.demo.utils;
using System.Collections;
using System.Collections.Generic;
using EasyUI.Toast;
public class GroupGetGroupInfoList : MonoBehaviour
{
  public HashSet<string> SelectedGroup = new HashSet<string>();
  public Text Header;
  public Text Result;
  private string Data;
  public List<string> ResultText;
  public Button Submit;
  public Button Copy;

  void Start()
  {
    GameObject.Find("SelectGroupLabel").GetComponent<Text>().text = Utils.t("SelectGroupLabel");
    GroupGetJoinedGroupListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GroupGetGroupInfoListSDK);
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
      SelectedGroup.Add(userID);
    }
    else
    {
      SelectedGroup.Remove(userID);
    }
  }

  void GenerateToggle(List<GroupBaseInfo> group_infos)
  {
    var Parent = GameObject.Find("ToggleContent");
    var Toggler = GameObject.Find("Toggler").GetComponent<Toggle>();
    foreach (GroupBaseInfo info in group_infos)
    {
      var obj = Instantiate(Toggler, Parent.transform);
      obj.GetComponentInChildren<Text>().text = "group_id:" + info.group_base_info_group_id;
      obj.isOn = false;
      obj.onValueChanged.AddListener(delegate
    {
      ToggleValueChanged(obj);
    });
    }
  }

  void SetGroupList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      List<GroupBaseInfo> List = Utils.FromJson<List<GroupBaseInfo>>(text);
      GenerateToggle(List);
    }
    catch (Exception ex)
    {
      print(ex);
      Toast.Show(Utils.t("getGroupListFailed"));
    }
  }

  public void GroupGetJoinedGroupListSDK()
  {
    var cb = Utils.addAsyncStringDataToScreen(SetGroupList);
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(cb);
  }

  public void GroupGetGroupInfoListSDK()
  {
    List<string> group_ids = new List<string>(SelectedGroup);
    TIMResult res = TencentIMSDK.GroupGetGroupInfoList(group_ids, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GenerateResultText()
  {
    var Parent = GameObject.Find("ResultPanel");
    foreach (Transform child in Parent.transform)
    {
      GameObject.Destroy(child.gameObject);
    }
    foreach (string resultText in ResultText)
    {
      var obj = Instantiate(Result, Parent.transform);
      obj.text = resultText;
    }
  }

  void GetResult(params object[] parameters)
  {
    ResultText = new List<string>();
    // ArgumentException: Mesh can not have more than 65000 vertices
    // Deal with a single Text cannot render too many words issue
    string CallbackData = (string)parameters[0];
    string[] DataList = CallbackData.Split('\n');
    int count = 0;
    while (count < DataList.Length)
    {
      // Every 400 lines render a new Text
      int end = count + 400;
      if (end > DataList.Length)
      {
        end = DataList.Length;
      }
      string[] textList = DataList.Skip(count).Take(end - count).ToArray();
      ResultText.Add(string.Join("\n", textList));
      count = end;
    }
    Data = (string)parameters[0];
    GenerateResultText();
  }

  void CopyText()
  {
    Utils.Copy(Data);
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}