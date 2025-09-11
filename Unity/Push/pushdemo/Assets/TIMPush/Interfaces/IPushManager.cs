using UnityEngine;
using com.tencent.timpush.unity;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Linq;
using System;
using System.Threading;

namespace com.tencent.timpush.unity.interfaces
{
    public interface IPushManager
    {
        public void RegisterPush(int sdkAppId, string appKey, PushCallback callback) {}

        public void UnRegisterPush(PushCallback callback) {}

        public void SetRegistrationID(string registrationID, PushCallback callback) {}

        public void GetRegistrationID(PushCallback callback) {}

        public void AddPushListener(PushListener listener) {}

        public void RemovePushListener(PushListener listener) {}

        public void ForceUseFCMPushChannel(bool enable) {}

        public void DisablePostNotificationInForeground(bool disable) {}

        public void SetPushToken(string pushToken) {}

        public void CallExperimentalAPI(string api, object param, PushCallback callback) {}
    }
}

