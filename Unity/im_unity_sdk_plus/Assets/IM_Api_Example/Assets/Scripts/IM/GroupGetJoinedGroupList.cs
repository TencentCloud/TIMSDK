using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using com.tencent.im.unity.demo.utils;
using System.Linq;
using System.Collections;
using System.Collections.Generic;
public class GroupGetJoinedGroupList : MonoBehaviour
{
  public Text Header;
  public Text Result;
  public Button Submit;
  public Button Copy;
  public List<string> ResultText;
  private string Data;

  void Start()
  {
    // Result = GameObject.Find("ResultText").GetComponent<Text>();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(GroupGetJoinedGroupListSDK);
    Copy.onClick.AddListener(CopyText);
  }
  void GroupGetJoinedGroupListSDK()
  {
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(Utils.addAsyncStringDataToScreen(GetResult));
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