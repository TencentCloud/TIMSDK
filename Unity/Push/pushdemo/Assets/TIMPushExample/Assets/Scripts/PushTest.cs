using UnityEngine;
using UnityEngine.UI;
using com.tencent.timpush.unity;
using System;
using System.Collections;
using System.Text;
using System.Collections.Generic;
using EasyUI.Toast;
using UnityEngine.Android;

public class PushTest : MonoBehaviour
{
  public InputField sdkAppID;
  public InputField appKey;
  public InputField registrationID;
  public Text resultText;
  public Toggle enable;
  public Toggle disable;
  public Button registerPush;
  public Button unregisterPush;
  public Button getRegistrationID;
  public Button setRegistrationID;
  public Button addPushListener;
  public Button removePushListener;
  public Button forceUseFCMPushChannel;
  public Button disablePostNotificationInForeground;
  public Button copy;
  public Button clear;

  private List<PushListener> pushListeners = new List<PushListener>();

  void Start()
  {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (Permission.HasUserAuthorizedPermission("android.permission.POST_NOTIFICATIONS"))
        {
            Debug.Log("通知权限已授权");
        }
        else
        {
            Permission.RequestUserPermission("android.permission.POST_NOTIFICATIONS");
        }
#endif
    sdkAppID = GameObject.Find("sdkAppID").GetComponent<InputField>();
    appKey = GameObject.Find("appKey").GetComponent<InputField>();
    registrationID = GameObject.Find("registrationID").GetComponent<InputField>();
    resultText = GameObject.Find("resultText").GetComponent<Text>();
    enable = GameObject.Find("enable").GetComponent<Toggle>();
    disable = GameObject.Find("disable").GetComponent<Toggle>();
    registerPush = GameObject.Find("RegisterPush").GetComponent<Button>();
    unregisterPush = GameObject.Find("UnRegisterPush").GetComponent<Button>();
    getRegistrationID = GameObject.Find("GetRegistrationID").GetComponent<Button>();
    setRegistrationID = GameObject.Find("SetRegistrationID").GetComponent<Button>();
    addPushListener = GameObject.Find("AddPushListener").GetComponent<Button>();
    removePushListener = GameObject.Find("RemovePushListener").GetComponent<Button>();
    forceUseFCMPushChannel = GameObject.Find("ForceUseFCMPushChannel").GetComponent<Button>();
    disablePostNotificationInForeground = GameObject.Find("DisablePostNotificationInForeground").GetComponent<Button>();
    copy = GameObject.Find("Copy").GetComponent<Button>();
    clear = GameObject.Find("Clear").GetComponent<Button>();

    registerPush.onClick.AddListener(RegisterPushTest);
    unregisterPush.onClick.AddListener(UnRegisterPushTest);
    getRegistrationID.onClick.AddListener(GetRegistrationIDTest);
    setRegistrationID.onClick.AddListener(SetRegistrationIDTest);
    addPushListener.onClick.AddListener(AddPushListenerTest);
    removePushListener.onClick.AddListener(RemovePushListenerTest);
    forceUseFCMPushChannel.onClick.AddListener(ForceUseFCMPushChannelTest);
    disablePostNotificationInForeground.onClick.AddListener(DisablePostNotificationInForegroundTest);
    copy.onClick.AddListener(CopyText);
    clear.onClick.AddListener(ClearText);

    Init();
  }

  void Init()
  {
    AddPushListenerTest();
    
    sdkAppID.text = PlayerPrefs.GetString("sdkAppID", "11111111");
    appKey.text = PlayerPrefs.GetString("appKey", "xxxxxxxx");
    registrationID.text = PlayerPrefs.GetString("registrationID", "bernie");

    resultText.text = "";
  }

  void RegisterPushTest()
  {
    int sdkAppIDTest = string.IsNullOrEmpty(this.sdkAppID.text) ? 0 : int.Parse(this.sdkAppID.text);
    string appKeyTest = string.IsNullOrEmpty(this.appKey.text) ? "" : this.appKey.text;

    PushManager.RegisterPush(sdkAppIDTest, appKeyTest, new PushCallback((data) =>
    {
      SetResultText($"注册推送成功: {data}");
      PlayerPrefs.SetString("sdkAppID", sdkAppIDTest.ToString());
      PlayerPrefs.SetString("appKey", appKeyTest);
    }, (errCode, errMsg, data) =>
    {
      SetResultText($"注册推送失败: 错误码:{errCode}, 错误信息:{errMsg}");
    }));
  }

  void UnRegisterPushTest()
  {
    PushManager.UnRegisterPush(new PushCallback((data) =>
    {
      SetResultText($"注销推送成功: {data}");
    }, (errCode, errMsg, data) =>
    {
      SetResultText($"注销推送失败: 错误码:{errCode}, 错误信息:{errMsg}");
    }));
  }

  void SetRegistrationIDTest()
  {
    string registrationIDTest = string.IsNullOrEmpty(this.registrationID.text) ? "" : this.registrationID.text;
    PushManager.SetRegistrationID(registrationIDTest, new PushCallback((data) =>
    {
      SetResultText($"设置推送 ID 成功: {data}");
      PlayerPrefs.SetString("registrationID", registrationIDTest);
    }, (errCode, errMsg, data) =>
    {
      SetResultText($"设置推送 ID 失败: 错误码:{errCode}, 错误信息:{errMsg}");
    }));
  }

  void GetRegistrationIDTest()
  {
    PushManager.GetRegistrationID(new PushCallback((data) =>
    {
      SetResultText($"获取推送 ID 成功: {data}");
    }, (errCode, errMsg, data) =>
    {
      SetResultText($"获取推送 ID 失败: 错误码:{errCode}, 错误信息:{errMsg}");
    }));
  }

  void AddPushListenerTest()
  {
    PushListener listener = new PushListener(onRecvPushMessage: (message) =>
    {
      SetResultText($"收到推送消息: 标题:{message.title}, 内容:{message.desc}, 透传内容:{message.ext}, 消息 ID:{message.messageID}");
    }, onRevokePushMessage: (messageID) =>
    {
      SetResultText($"撤销推送消息 ID: {messageID}");
    }, onNotificationClicked: (ext) =>
    {
      SetResultText($"点击推送消息: {ext}");
    });

    pushListeners.Add(listener);
    PushManager.AddPushListener(listener);
    SetResultText($"添加推送监听成功，推送监听个数:{pushListeners.Count}");
  }

  void RemovePushListenerTest()
  {
    if (pushListeners.Count > 0)
    {
      PushManager.RemovePushListener(pushListeners[0]);
      pushListeners.RemoveAt(0);
      SetResultText($"移除最早添加的推送监听成功，剩余推送监听个数:{pushListeners.Count}");
    }
    else
    {
      SetResultText("没有推送监听");
    }
  }

  void ForceUseFCMPushChannelTest()
  {
    PushManager.ForceUseFCMPushChannel(enable.isOn);
    SetResultText($"强制使用 FCM 推送通道: {enable.isOn}");
  }

  void DisablePostNotificationInForegroundTest()
  {
    PushManager.DisablePostNotificationInForeground(disable.isOn);
    SetResultText($"禁用前台通知: {disable.isOn}");
  }

  void CallExperimentalAPITest()
  {
    PushManager.CallExperimentalAPI("setPushToken", "test setPushToken api", new PushCallback((data) =>
    {
      SetResultText($"设置推送 token 成功: {data}");
    }, (errCode, errMsg, data) =>
    {
      SetResultText($"设置推送 token 失败: 错误码:{errCode}, 错误信息:{errMsg}");
    }));

    PushManager.CallExperimentalAPI("setAppLanguage", "zh-CN", new PushCallback((data) =>
    {
      SetResultText($"设置 app 语言成功: {data}");
    }, (errCode, errMsg, data) =>
    {
      SetResultText($"设置 app 语言失败: 错误码:{errCode}, 错误信息:{errMsg}");
    }));

    PushManager.CallExperimentalAPI("setCustomBadgeNumber", 6, new PushCallback((data) =>
    {
      SetResultText($"设置自定义角标成功: {data}");
    }, (errCode, errMsg, data) =>
    {
      SetResultText($"设置自定义角标失败: 错误码:{errCode}, 错误信息:{errMsg}");
    }));
  }

  void CopyText()
  {
    var copyContent = resultText.text;
    TextEditor editor = new TextEditor();
    editor.text = copyContent;
    editor.SelectAll();
    editor.Copy();
    Toast.Show("Copied, 已复制");
  }

  void ClearText()
  {
    resultText.text = "";
  }

  void SetResultText(string text)
  {
    Debug.Log(text);
    resultText.text += text + "\n";
  }

  void OnApplicationQuit()
  {
  }
}