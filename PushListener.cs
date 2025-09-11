using UnityEngine;
using System;

namespace com.tencent.timpush.unity
{
    public class PushListener
    {
        public Action<PushMessage> onRecvPushMessage;
        public Action<string> onRevokePushMessage;
        public Action<string> onNotificationClicked;

        private AndroidJavaObject _listenerObject;

        public PushListener(Action<PushMessage> onRecvPushMessage = null, Action<string> onRevokePushMessage = null, Action<string> onNotificationClicked = null)
        {
            this.onRecvPushMessage = onRecvPushMessage;
            this.onRevokePushMessage = onRevokePushMessage;
            this.onNotificationClicked = onNotificationClicked;
        }

        public void SetListenerObject(AndroidJavaObject listenerObject)
        {
            this._listenerObject = listenerObject;
        }

        public AndroidJavaObject GetListenerObject()
        {
            return this._listenerObject;
        }
    }
}