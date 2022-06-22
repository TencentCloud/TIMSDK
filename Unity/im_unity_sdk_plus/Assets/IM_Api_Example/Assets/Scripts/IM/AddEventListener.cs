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
public class AddEventListener : MonoBehaviour
{
  public Text Header;
  public Transform ButtonArea;
  public List<EventListenerData> dataList;

  void Start()
  {
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    ButtonArea = GameObject.Find("FormPanel").GetComponent<Transform>();
    if (CurrentSceneInfo.info != null)
    {
      Header.text = CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName;
    }
    var Parent = GameObject.Find("Form");
    dataList = Utils.FromJson<List<EventListenerData>>(EventListenerList.EventListenerListStr);
    for (int i = 0; i < dataList.Count; i++)
    {
      var obj = Instantiate(ButtonArea, Parent.transform);
      Button btn = obj.GetComponentInChildren<Button>();
      string eventName = dataList[i].eventName;
      btn.name = eventName;
      btn.GetComponentInChildren<Text>().text = "注册 " + dataList[i].eventText;
      RenderButton(eventName, btn);
    }
  }

  void RenderButton(string eventName, Button btn)
  {
    bool hasEvent = EventListenerInfo.Info.ContainsKey(eventName);
    if (hasEvent)
    {
      btn.onClick.RemoveAllListeners();
      btn.onClick.AddListener(() => RemoveEventListenerSDK(eventName));
      btn.GetComponentInChildren<Text>().text = "注销 " + btn.GetComponentInChildren<Text>().text.Split(' ')[1];
      btn.GetComponentInChildren<Image>().color = new Color(1, 0.345f, 0.298f, 1);
    }
    else
    {
      btn.onClick.RemoveAllListeners();
      btn.onClick.AddListener(() => AddEventListenerSDK(eventName));
      btn.GetComponentInChildren<Text>().text = "注册 " + btn.GetComponentInChildren<Text>().text.Split(' ')[1];
      btn.GetComponentInChildren<Image>().color = new Color(0.192f, 0.345f, 0.533f, 1);
    }
  }

  void RemoveEventListenerSDK(string eventName)
  {
    switch (eventName)
    {
      case "AddRecvNewMsgCallback":
        {
          TencentIMSDK.RemoveRecvNewMsgCallback();
          break;
        }
      case "SetMsgReadedReceiptCallback":
        {
          TencentIMSDK.SetMsgReadedReceiptCallback();
          break;
        }
      case "SetMsgRevokeCallback":
        {
          TencentIMSDK.SetMsgRevokeCallback();
          break;
        }
      case "SetGroupTipsEventCallback":
        {
          TencentIMSDK.SetGroupTipsEventCallback();
          break;
        }
      case "SetMsgElemUploadProgressCallback":
        {
          TencentIMSDK.SetMsgElemUploadProgressCallback();
          break;
        }
      default:
        {
          print($"Unknown event {eventName}");
          break;
        }
    }
    EventListenerInfo.Info.Remove(eventName);
    Button btn = GameObject.Find(eventName).GetComponent<Button>();
    RenderButton(eventName, btn);
  }
  void AddEventListenerSDK(string eventName)
  {
    var eventInfo = new EventListenerInfo.EventInfo();
    EventListenerInfo.Info.Add(eventName, eventInfo);
    switch (eventName)
    {
      case "AddRecvNewMsgCallback":
        {
          TencentIMSDK.AddRecvNewMsgCallback(null, Utils.RecvNewMsgCallback(GetResult, eventInfo));
          break;
        }
      case "SetMsgReadedReceiptCallback":
        {
          TencentIMSDK.SetMsgReadedReceiptCallback(null, Utils.SetMsgReadedReceiptCallback(GetResult, eventInfo));
          break;
        }
      case "SetMsgRevokeCallback":
        {
          TencentIMSDK.SetMsgRevokeCallback(null, Utils.SetMsgRevokeCallback(GetResult, eventInfo));
          break;
        }
      case "SetGroupTipsEventCallback":
        {
          TencentIMSDK.SetGroupTipsEventCallback(null, Utils.SetGroupTipsEventCallback(GetResult, eventInfo));
          break;
        }
      case "SetMsgElemUploadProgressCallback":
        {
          TencentIMSDK.SetMsgElemUploadProgressCallback(null, Utils.SetMsgElemUploadProgressCallback(GetResult, eventInfo));
          break;
        }
      default:
        {
          print($"Unknown event {eventName}");
          break;
        }
    }
    Button btn = GameObject.Find(eventName).GetComponent<Button>();
    RenderButton(eventName, btn);
  }

  void GetResult(EventListenerInfo.EventInfo eventInfo, params object[] parameters)
  {
    string CallbackData = (string)parameters[0];
    eventInfo.Result = CallbackData;
  }

  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}