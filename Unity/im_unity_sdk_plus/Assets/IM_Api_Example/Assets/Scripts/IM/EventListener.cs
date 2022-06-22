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
  void Start()
  {
    Transform ResultArea = GameObject.Find("ResultArea").GetComponent<Transform>();
    var Parent = GameObject.Find("ResultPanel");
    foreach (KeyValuePair<string, EventListenerInfo.EventInfo> entry in EventListenerInfo.Info)
    {
      var obj = Instantiate(ResultArea, Parent.transform);
      Text ResultText = obj.Find("Panel/ResultText").GetComponent<Text>();
      ResultText.text = Utils.PrefixEventCallbackData(entry.Key, entry.Value.Result);
      entry.Value.notifyPropertyChanged = (string text) =>
    {
      print(text);
      ResultText.text = Utils.PrefixEventCallbackData(entry.Key, text);
    };
      Button copy = obj.GetComponentInChildren<Button>();
      copy.onClick.AddListener(() => Utils.Copy(ResultText.text));
    }
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}