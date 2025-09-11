using UnityEngine;
using com.tencent.timpush.unity;
using com.tencent.timpush.unity.interfaces;

namespace com.tencent.timpush.unity.platforms
{
    public class EditorPushManager : IPushManager
    {
        public void RegisterPush(int sdkAppId, string appKey, PushCallback callback)
        {
            Debug.Log("not support editor");
        }

        public void UnRegisterPush(PushCallback callback)
        {
            Debug.Log("not support editor");
        }

        public void SetRegistrationID(string registrationID, PushCallback callback)
        {
            Debug.Log("not support editor");
        }

        public void GetRegistrationID(PushCallback callback)
        {
            Debug.Log("not support editor");
        }

        public void AddPushListener(PushListener listener)
        {
            Debug.Log("not support editor");
        }

        public void RemovePushListener(PushListener listener)
        {
            Debug.Log("not support editor");
        }

        public void ForceUseFCMPushChannel(bool enable)
        {
            Debug.Log("not support editor");
        }

        public void DisablePostNotificationInForeground(bool disable)
        {
            Debug.Log("not support editor");
        }

        public void CallExperimentalAPI(string api, object param, PushCallback callback)
        {
            Debug.Log("not support editor");
        }
    }
}