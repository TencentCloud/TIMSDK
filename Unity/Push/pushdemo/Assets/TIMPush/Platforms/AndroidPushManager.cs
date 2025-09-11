using UnityEngine;
using UnityEngine.Android;
using com.tencent.timpush.unity;
using com.tencent.timpush.unity.interfaces;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Linq;
using System;
using System.Threading;

namespace com.tencent.timpush.unity.platforms
{
    public class AndroidPushManager : IPushManager
    {
        private static SynchronizationContext _mainSyncContext = SynchronizationContext.Current;
        private static AndroidJavaClass _timPushManagerClass = new AndroidJavaClass("com.tencent.qcloud.tim.push.TIMPushManager");
        private static AndroidJavaObject _timPushManagerInstance = _timPushManagerClass.CallStatic<AndroidJavaObject>("getInstance");
        private static AndroidJavaClass _nativePushCallbackClass = new AndroidJavaClass("com.tencent.qcloud.tim.push.unity.UnityPushCallback");
        private static AndroidJavaClass _nativePushListenerClass = new AndroidJavaClass("com.tencent.qcloud.tim.push.unity.UnityPushListener");
        private static AndroidJavaClass _unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer");

        public void RegisterPush(int sdkAppId, string appKey, PushCallback callback)
        {
            CallExperimentalAPI("setPushConfig", "{\"runningPlatform\":7}", new PushCallback());

            AndroidJavaObject activity = _unityPlayer.GetStatic<AndroidJavaObject>("currentActivity");

            Java2CSharpCallback pushCallback = new Java2CSharpCallback(
                callback.onSuccess,
                callback.onError
            );
            AndroidJavaObject callbackObject = _nativePushCallbackClass.CallStatic<AndroidJavaObject>("createPushCallback", pushCallback);

            _timPushManagerInstance.Call(
                "registerPush",
                activity,
                sdkAppId,
                appKey,
                callbackObject
            );
        }

        public void UnRegisterPush(PushCallback callback)
        {
            Java2CSharpCallback pushCallback = new Java2CSharpCallback(
                callback.onSuccess,
                callback.onError
            );
            AndroidJavaObject callbackObject = _nativePushCallbackClass.CallStatic<AndroidJavaObject>("createPushCallback", pushCallback);

            _timPushManagerInstance.Call(
                "unRegisterPush",
                callbackObject
            );
        }


        public void SetRegistrationID(string registrationID, PushCallback callback)
        {
            Java2CSharpCallback pushCallback = new Java2CSharpCallback(
                callback.onSuccess,
                callback.onError
            );
            AndroidJavaObject callbackObject = _nativePushCallbackClass.CallStatic<AndroidJavaObject>("createPushCallback", pushCallback);

            _timPushManagerInstance.Call(
                "setRegistrationID",
                registrationID,
                callbackObject
            );
        }

        public void GetRegistrationID(PushCallback callback)
        {
            Java2CSharpCallback pushCallback = new Java2CSharpCallback(
                callback.onSuccess,
                callback.onError
            );
            AndroidJavaObject callbackObject = _nativePushCallbackClass.CallStatic<AndroidJavaObject>("createPushCallback", pushCallback);

            _timPushManagerInstance.Call(
                "getRegistrationID",
                callbackObject
            );
        }

        public void AddPushListener(PushListener listener)
        {
            Java2CSharpListenerHelper listenerHelper = new Java2CSharpListenerHelper(
                listener.onRecvPushMessage,
                listener.onRevokePushMessage,
                listener.onNotificationClicked
            );
            AndroidJavaObject listenerObject = _nativePushListenerClass.CallStatic<AndroidJavaObject>("createPushListener", listenerHelper);
            listener.SetListenerObject(listenerObject);

            _timPushManagerInstance.Call(
                "addPushListener",
                listenerObject
            );
        }

        public void RemovePushListener(PushListener listener)
        {
            AndroidJavaObject listenerObject = listener.GetListenerObject();
            if (listenerObject == null)
            {
                Debug.LogError("listenerObject is null");
                return;
            }

            _timPushManagerInstance.Call(
                "removePushListener",
                listenerObject
            );
        }

        public void ForceUseFCMPushChannel(bool enable)
        {
            _timPushManagerInstance.Call(
                "forceUseFCMPushChannel",
                enable
            );
        }

        public void DisablePostNotificationInForeground(bool disable)
        {
            _timPushManagerInstance.Call(
                "disablePostNotificationInForeground",
                disable
            );
        }

        public void CallExperimentalAPI(string api, object param, PushCallback callback)
        {
            Java2CSharpCallback pushCallback = new Java2CSharpCallback(
                callback.onSuccess,
                callback.onError
            );
            AndroidJavaObject callbackObject = _nativePushCallbackClass.CallStatic<AndroidJavaObject>("createPushCallback", pushCallback);

            _timPushManagerInstance.Call(
                "callExperimentalAPI",
                api,
                param,
                callbackObject
            );
        }

        public class Java2CSharpCallback : AndroidJavaProxy
        {
            public Action<object> onSuccessDelegate;
            public Action<int, string, object> onErrorDelegate;

            public Java2CSharpCallback(Action<object> onSuccess, Action<int, string, object> onError) : base("com.tencent.qcloud.tim.push.unity.UnityPushCallback$IJava2CSharpCallback")
            {
                this.onSuccessDelegate = onSuccess;
                this.onErrorDelegate = onError;
            }

            public void onSuccess(object data)
            {
                _mainSyncContext.Post(_ =>
                {
                    this.onSuccessDelegate?.Invoke(data);
                }, null);
            }
            public void onError(int errCode, string errMsg, object data)
            {
                _mainSyncContext.Post(_ =>
                {
                    this.onErrorDelegate?.Invoke(errCode, errMsg, data);
                }, null);
            }
        }

        public class Java2CSharpListenerHelper : AndroidJavaProxy
        {
            public Action<PushMessage> onRecvPushMessageDelegate;
            public Action<string> onRevokePushMessageDelegate;
            public Action<string> onNotificationClickedDelegate;

            public Java2CSharpListenerHelper(Action<PushMessage> onRecvPushMessage, Action<string> onRevokePushMessage, Action<string> onNotificationClicked) : base("com.tencent.qcloud.tim.push.unity.UnityPushListener$IJava2CSharpListener")
            {
                this.onRecvPushMessageDelegate = onRecvPushMessage;
                this.onRevokePushMessageDelegate = onRevokePushMessage;
                this.onNotificationClickedDelegate = onNotificationClicked;
            }

            public void onRecvPushMessage(AndroidJavaObject data)
            {
                _mainSyncContext.Post(_ =>
                {
                    this.onRecvPushMessageDelegate?.Invoke(new PushMessage(data));
                }, null);
            }

            public void onRevokePushMessage(string messageID)
            {
                _mainSyncContext.Post(_ =>
                {
                    this.onRevokePushMessageDelegate?.Invoke(messageID);
                }, null);
            }

            public void onNotificationClicked(string ext)
            {
                _mainSyncContext.Post(_ =>
                {
                    this.onNotificationClickedDelegate?.Invoke(ext);
                }, null);
            }
        }
    }
}

