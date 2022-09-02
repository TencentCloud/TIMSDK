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
using com.tencent.im.unity.demo.config.EventListenerList;
public class EventListener : MonoBehaviour
{
  Text ResultText;
  void Start()
  {
    ResultText = GameObject.Find("ResultText").GetComponent<Text>();
    GameObject.Find("HeaderText").GetComponent<Text>().text = Utils.t("EventListener");
    Transform ResultArea = GameObject.Find("ResultArea").GetComponent<Transform>();
    var Parent = GameObject.Find("ResultPanel");
    foreach (KeyValuePair<string, EventListenerInfo.EventInfo> entry in EventListenerInfo.Info)
    {
      var obj = Instantiate(ResultArea, Parent.transform);
      var TextPanel = obj.Find("Panel");
      // var InitText = Instantiate(ResultText, TextPanel.transform);
      // InitText.text = Utils.PrefixEventCallbackData(entry.Key, entry.Value.Result);
      GenerateResultText(entry, TextPanel, entry.Value.Result);
      entry.Value.notifyPropertyChanged = (string text) =>
    {
      GenerateResultText(entry, TextPanel, text);
    };
      Button Copy = obj.GetComponentInChildren<Button>();
      Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
      Copy.onClick.AddListener(() => Utils.Copy(entry.Value.Result));
    }
  }
  List<string> GetResult(string text)
  {
    List<string> ResultText = new List<string>();
    // ArgumentException: Mesh can not have more than 65000 vertices
    // Deal with a single Text cannot render too many words issue
    string[] DataList = text.Split('\n');
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
    return ResultText;
  }

  void GenerateResultText(KeyValuePair<string, EventListenerInfo.EventInfo> entry, Transform TextPanel, string text)
  {
    if (TextPanel == null) return;
    string showText = Utils.PrefixEventCallbackData(entry.Key, text);
    List<string> showTextList = GetResult(showText);
    foreach (Transform child in TextPanel.transform)// 收拾收拾
    {
      GameObject.Destroy(child.gameObject);
    }
    foreach (string chunk in showTextList)
    {
      var newText = Instantiate(ResultText, TextPanel.transform);
      newText.text = chunk;
    }
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}