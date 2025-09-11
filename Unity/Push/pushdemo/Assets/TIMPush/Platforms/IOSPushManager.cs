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
using System.Diagnostics;
using AOT;

namespace com.tencent.timpush.unity.platforms
{
#if UNITY_IOS && !UNITY_EDITOR
    public class IOSPushManager : IPushManager {
        #region DllImport C APIs

        [DllImport("__Internal")]
        private static extern void TIMRegisterPush(int sdkAppId, IntPtr appKey,
            TIMPushSuccessCallbackDelegate successCallback, TIMPushFailedCallbackDelegate failedCallback, IntPtr userData);

        [DllImport("__Internal")]
        private static extern void TIMUnRegisterPush(TIMPushSuccessCallbackDelegate successCallback,
            TIMPushFailedCallbackDelegate failedCallback, IntPtr userData);

        [DllImport("__Internal")]
        private static extern void TIMGetRegistrationID(TIMPushSuccessCallbackDelegate callback, IntPtr userData);

        [DllImport("__Internal")]
        private static extern void TIMSetRegistrationID(IntPtr registrationID, TIMPushSuccessCallbackDelegate callback, IntPtr userData);

        [DllImport("__Internal")]
        private static extern void TIMDisablePostNotificationInForeground(bool disable);

        [DllImport("__Internal")]
        private static extern void TIMAddPushListener(PushMessageCallbackDelegate messageCallback,
            TIMPushRevokeCallbackDelegate revokeCallback, TIMPushNotificationClickedCallbackDelegate clickedCallback);

        [DllImport("__Internal")]
        private static extern void TIMRemovePushListener();

        [DllImport("__Internal")]
        private static extern void TIMCallExperimentalAPI(IntPtr api, IntPtr paramStr, int paramInt,
            TIMPushSuccessCallbackDelegate successCallback, TIMPushFailedCallbackDelegate failedCallback, IntPtr userData);

        #endregion

        #region Callback Delegates

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMPushSuccessCallbackDelegate(IntPtr data, IntPtr userData);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMPushFailedCallbackDelegate(int code, IntPtr desc, IntPtr userData);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void PushMessageCallbackDelegate(IntPtr message);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMPushRevokeCallbackDelegate(IntPtr messageID);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMPushNotificationClickedCallbackDelegate(IntPtr ext);

        #endregion


        private static SynchronizationContext _mainSyncContext = SynchronizationContext.Current;
        private static Dictionary<string, PushCallback> callbackStore = new Dictionary<string, PushCallback>();
        private static HashSet<PushListener> listenerStore = new HashSet<PushListener>();

        public void RegisterPush(int sdkAppId, string appKey, PushCallback callback) {
            CallExperimentalAPI("setPushConfig", "{\"runningPlatform\":7}", new PushCallback());

            IntPtr appKeyPtr = String2IntPtr(appKey);
            string callbackKey = CallbackKeyGenerator.GetCallbackKey("RegisterPush");
            callbackStore.Add(callbackKey, callback);
            IntPtr callbackKeyPtr = String2IntPtr(callbackKey);
            TIMRegisterPush(sdkAppId, appKeyPtr, OnSuccessCallback, OnFailedCallback, callbackKeyPtr);
            Marshal.FreeHGlobal(appKeyPtr);

            TIMAddPushListener(OnMessageCallback, OnRevokeCallback, OnNotificationClickedCallback);
        }

        public void UnRegisterPush(PushCallback callback) {
            string callbackKey = CallbackKeyGenerator.GetCallbackKey("UnRegisterPush");
            callbackStore.Add(callbackKey, callback);
            IntPtr callbackKeyPtr = String2IntPtr(callbackKey);
            TIMUnRegisterPush(OnSuccessCallback, OnFailedCallback, callbackKeyPtr);

            TIMRemovePushListener();
        }

        public void SetRegistrationID(string registrationID, PushCallback callback) {
            string callbackKey = CallbackKeyGenerator.GetCallbackKey("SetRegistrationID");
            callbackStore.Add(callbackKey, callback);
            IntPtr registrationIDPtr = String2IntPtr(registrationID);
            IntPtr callbackKeyPtr = String2IntPtr(callbackKey);
            TIMSetRegistrationID(registrationIDPtr, OnSuccessCallback, callbackKeyPtr);
            Marshal.FreeHGlobal(registrationIDPtr);
        }

        public void GetRegistrationID(PushCallback callback) {
            string callbackKey = CallbackKeyGenerator.GetCallbackKey("GetRegistrationID");
            callbackStore.Add(callbackKey, callback);
            IntPtr callbackKeyPtr = String2IntPtr(callbackKey);
            TIMGetRegistrationID(OnSuccessCallback, callbackKeyPtr);
        }

        public void AddPushListener(PushListener listener) {
            listenerStore.Add(listener);
        }

        public void RemovePushListener(PushListener listener) {
            listenerStore.Remove(listener);
        }

        public void ForceUseFCMPushChannel(bool enable) {
            UnityEngine.Debug.Log("not support ios");
        }

        public void DisablePostNotificationInForeground(bool disable) {
            TIMDisablePostNotificationInForeground(disable);
        }

        public void CallExperimentalAPI(string api, object param, PushCallback callback) {
            string paramStr = "";
            int paramInt = 0;
            if (param is string) {
                paramStr = (string)param;
            } else if (param is int) {
                paramInt = (int)param;
            }

            string callbackKey = CallbackKeyGenerator.GetCallbackKey("CallExperimentalAPI");
            callbackStore.Add(callbackKey, callback);
            IntPtr apiPtr = String2IntPtr(api);
            IntPtr paramPtr = paramStr.Length > 0 ? String2IntPtr(paramStr) : IntPtr.Zero;
            IntPtr callbackKeyPtr = String2IntPtr(callbackKey);
            TIMCallExperimentalAPI(apiPtr, paramPtr, paramInt, OnSuccessCallback, OnFailedCallback, callbackKeyPtr);
            Marshal.FreeHGlobal(apiPtr);
            if (paramPtr != IntPtr.Zero) {
                Marshal.FreeHGlobal(paramPtr);
            }
        }

        [MonoPInvokeCallback(typeof(TIMPushSuccessCallbackDelegate))]
        public static void OnSuccessCallback(IntPtr data, IntPtr userDataPtr) {
            string userData = IntPtr2String(userDataPtr);
            string dataStr = IntPtr2String(data);
            if (callbackStore.TryGetValue(userData, out PushCallback callback)) {
                _mainSyncContext.Post(_ => {
                    callback.onSuccess?.Invoke(dataStr);
                    callbackStore.Remove(userData);
                    Marshal.FreeHGlobal(userDataPtr);
                }, null);
            }
        }

        [MonoPInvokeCallback(typeof(TIMPushFailedCallbackDelegate))]
        public static void OnFailedCallback(int code, IntPtr desc, IntPtr userDataPtr) {
            string userData = IntPtr2String(userDataPtr);
            string descStr = IntPtr2String(desc);
            if (callbackStore.TryGetValue(userData, out PushCallback callback)) {
                _mainSyncContext.Post(_ => {
                    callback.onError?.Invoke(code, descStr, "");
                    callbackStore.Remove(userData);
                    Marshal.FreeHGlobal(userDataPtr);
                }, null);
            }
        }

        [MonoPInvokeCallback(typeof(PushMessageCallbackDelegate))]
        public static void OnMessageCallback(IntPtr message) {
            string messageStr = IntPtr2String(message);
            foreach (PushListener listener in listenerStore) {
                _mainSyncContext.Post(_ => {
                    listener.onRecvPushMessage?.Invoke(PushMessage.FromJson(messageStr));
                }, null); 
            }
        }

        [MonoPInvokeCallback(typeof(TIMPushRevokeCallbackDelegate))]
        public static void OnRevokeCallback(IntPtr messageID) {
            string messageIDStr = IntPtr2String(messageID);
            foreach (PushListener listener in listenerStore) {
                _mainSyncContext.Post(_ => {
                    listener.onRevokePushMessage?.Invoke(messageIDStr);
                }, null);
            }
        }

        [MonoPInvokeCallback(typeof(TIMPushNotificationClickedCallbackDelegate))]
        public static void OnNotificationClickedCallback(IntPtr ext) {
            string extStr = IntPtr2String(ext);
            foreach (PushListener listener in listenerStore) {
                _mainSyncContext.Post(_ => {
                    listener.onNotificationClicked?.Invoke(extStr);
                }, null);
            }
        }

        private static IntPtr String2IntPtr(string str) {
            byte[] utf8Bytes = Encoding.UTF8.GetBytes(str);
            IntPtr ptr = Marshal.AllocHGlobal(utf8Bytes.Length + 1);
            Marshal.Copy(utf8Bytes, 0, ptr, utf8Bytes.Length);
            Marshal.WriteByte(ptr, utf8Bytes.Length, 0);
            return ptr;
        }

        private static string IntPtr2String(IntPtr ptr) {
            return Marshal.PtrToStringUTF8(ptr) ?? "";
        }

        private class CallbackKeyGenerator {
            private static int callbackIndex = 0;

            public static string GetCallbackKey(string apiName) {
                return $"{apiName}_{callbackIndex++}";
            }
        }
    }
#endif
}