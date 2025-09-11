using UnityEngine;
using System;

namespace com.tencent.timpush.unity
{
    public class PushCallback
    {
        public Action<object> onSuccess;
        public Action<int, string, object> onError;

        public PushCallback(Action<object> onSuccess = null, Action<int, string, object> onError = null)
        {
            this.onSuccess = onSuccess;
            this.onError = onError;
        }
    }
}