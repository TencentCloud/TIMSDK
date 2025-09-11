using UnityEngine;
using UnityEngine.Android;
using com.tencent.timpush.unity.interfaces;
using com.tencent.timpush.unity.platforms;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Linq;
using System;
using System.Threading;

namespace com.tencent.timpush.unity
{
    public class PushManager
    {
        private static IPushManager _instance = null;
        public static IPushManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    try
                    {
#if UNITY_ANDROID && !UNITY_EDITOR
                         _instance = new AndroidPushManager();
#elif UNITY_IOS && !UNITY_EDITOR
                         _instance = new IOSPushManager();
#else
                        _instance = new EditorPushManager();
#endif
                    }
                    catch (Exception ex)
                    {
                        Debug.LogError($"Init PushManager instance failed: {ex}");
                        _instance = null;
                    }
                }
                return _instance;
            }
        }

        public static void RegisterPush(int sdkAppId, string appKey, PushCallback callback) => Instance?.RegisterPush(sdkAppId, appKey, callback);
        public static void UnRegisterPush(PushCallback callback) => Instance?.UnRegisterPush(callback);
        public static void SetRegistrationID(string registrationID, PushCallback callback) => Instance?.SetRegistrationID(registrationID, callback);
        public static void GetRegistrationID(PushCallback callback) => Instance?.GetRegistrationID(callback);
        public static void AddPushListener(PushListener listener) => Instance?.AddPushListener(listener);
        public static void RemovePushListener(PushListener listener) => Instance?.RemovePushListener(listener);
        public static void ForceUseFCMPushChannel(bool enable) => Instance?.ForceUseFCMPushChannel(enable);
        public static void DisablePostNotificationInForeground(bool disable) => Instance?.DisablePostNotificationInForeground(disable);
        public static void CallExperimentalAPI(string api, object param, PushCallback callback) => Instance?.CallExperimentalAPI(api, param, callback);
    }
}
