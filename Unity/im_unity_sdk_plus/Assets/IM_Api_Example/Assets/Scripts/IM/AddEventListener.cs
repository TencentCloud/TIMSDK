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
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
    }
    var Parent = GameObject.Find("Form");
    dataList = Utils.FromJson<List<EventListenerData>>(EventListenerList.EventListenerListStr);
    for (int i = 0; i < dataList.Count; i++)
    {
      var obj = Instantiate(ButtonArea, Parent.transform);
      Button btn = obj.GetComponentInChildren<Button>();
      string eventName = dataList[i].eventName;
      btn.name = eventName;
      btn.GetComponentInChildren<Text>().text = "注册 " + Utils.t(dataList[i].eventName);
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
      btn.GetComponentInChildren<Text>().text = Utils.t("remove") + " " + btn.GetComponentInChildren<Text>().text.Split(' ')[1];
      btn.GetComponentInChildren<Image>().color = new Color(1, 0.345f, 0.298f, 1);
    }
    else
    {
      btn.onClick.RemoveAllListeners();
      btn.onClick.AddListener(() => AddEventListenerSDK(eventName));
      btn.GetComponentInChildren<Text>().text = Utils.t("register") + " " + btn.GetComponentInChildren<Text>().text.Split(' ')[1];
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
      case "SetGroupAttributeChangedCallback":
        {
          TencentIMSDK.SetGroupAttributeChangedCallback();
          break;
        }
      case "SetConvEventCallback":
        {
          TencentIMSDK.SetConvEventCallback();
          break;
        }
      case "SetConvTotalUnreadMessageCountChangedCallback":
        {
          TencentIMSDK.SetConvTotalUnreadMessageCountChangedCallback(null);
          break;
        }
      case "SetNetworkStatusListenerCallback":
        {
          TencentIMSDK.SetNetworkStatusListenerCallback(null);
          break;
        }
      case "SetKickedOfflineCallback":
        {
          TencentIMSDK.SetKickedOfflineCallback(null);
          break;
        }
      case "SetUserSigExpiredCallback":
        {
          TencentIMSDK.SetUserSigExpiredCallback(null);
          break;
        }
      case "SetOnAddFriendCallback":
        {
          TencentIMSDK.SetOnAddFriendCallback(null);
          break;
        }
      case "SetOnDeleteFriendCallback":
        {
          TencentIMSDK.SetOnDeleteFriendCallback(null);
          break;
        }
      case "SetUpdateFriendProfileCallback":
        {
          TencentIMSDK.SetUpdateFriendProfileCallback(null);
          break;
        }
      case "SetFriendAddRequestCallback":
        {
          TencentIMSDK.SetFriendAddRequestCallback(null);
          break;
        }
      case "SetFriendApplicationListDeletedCallback":
        {
          TencentIMSDK.SetFriendApplicationListDeletedCallback(null);
          break;
        }
      case "SetFriendApplicationListReadCallback":
        {
          TencentIMSDK.SetFriendApplicationListReadCallback(null);
          break;
        }
      case "SetFriendBlackListAddedCallback":
        {
          TencentIMSDK.SetFriendBlackListAddedCallback(null);
          break;
        }
      case "SetFriendBlackListDeletedCallback":
        {
          TencentIMSDK.SetFriendBlackListDeletedCallback(null);
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
      case "SetGroupAttributeChangedCallback":
        {
          TencentIMSDK.SetGroupAttributeChangedCallback(null, Utils.SetGroupAttributeChangedCallback(GetResult, eventInfo));
          break;
        }
      case "SetConvEventCallback":
        {
          TencentIMSDK.SetConvEventCallback(null, Utils.SetConvEventCallback(GetResult, eventInfo));
          break;
        }
      case "SetConvTotalUnreadMessageCountChangedCallback":
        {
          TencentIMSDK.SetConvTotalUnreadMessageCountChangedCallback(Utils.SetConvTotalUnreadMessageCountChangedCallback(GetResult, eventInfo));
          break;
        }
      case "SetNetworkStatusListenerCallback":
        {
          TencentIMSDK.SetNetworkStatusListenerCallback(Utils.SetNetworkStatusListenerCallback(GetResult, eventInfo));
          break;
        }
      case "SetKickedOfflineCallback":
        {
          TencentIMSDK.SetKickedOfflineCallback(Utils.SetKickedOfflineCallback(GetResult, eventInfo));
          break;
        }
      case "SetUserSigExpiredCallback":
        {
          TencentIMSDK.SetUserSigExpiredCallback(Utils.SetUserSigExpiredCallback(GetResult, eventInfo));
          break;
        }
      case "SetOnAddFriendCallback":
        {
          TencentIMSDK.SetOnAddFriendCallback(null, Utils.SetOnAddFriendCallback(GetResult, eventInfo));
          break;
        }
      case "SetOnDeleteFriendCallback":
        {
          TencentIMSDK.SetOnDeleteFriendCallback(null, Utils.SetOnDeleteFriendCallback(GetResult, eventInfo));
          break;
        }
      case "SetUpdateFriendProfileCallback":
        {
          TencentIMSDK.SetUpdateFriendProfileCallback(null, Utils.SetUpdateFriendProfileCallback(GetResult, eventInfo));
          break;
        }
      case "SetFriendAddRequestCallback":
        {
          TencentIMSDK.SetFriendAddRequestCallback(null, Utils.SetFriendAddRequestCallback(GetResult, eventInfo));
          break;
        }
      case "SetFriendApplicationListDeletedCallback":
        {
          TencentIMSDK.SetFriendApplicationListDeletedCallback(null, Utils.SetFriendApplicationListDeletedCallback(GetResult, eventInfo));
          break;
        }
      case "SetFriendApplicationListReadCallback":
        {
          TencentIMSDK.SetFriendApplicationListReadCallback(Utils.SetFriendApplicationListReadCallback(GetResult, eventInfo));
          break;
        }
      case "SetFriendBlackListAddedCallback":
        {
          TencentIMSDK.SetFriendBlackListAddedCallback(null, Utils.SetFriendBlackListAddedCallback(GetResult, eventInfo));
          break;
        }
      case "SetFriendBlackListDeletedCallback":
        {
          TencentIMSDK.SetFriendBlackListDeletedCallback(null, Utils.SetFriendBlackListDeletedCallback(GetResult, eventInfo));
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