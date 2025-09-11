using UnityEngine;
using System;
using System.Runtime.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace com.tencent.timpush.unity
{
    public class PushMessage
    {
        // 离线推送标题
        public string title;
        // 离线推送内容
        public string desc;
        // 离线推送透传内容
        public string ext;
        // 消息唯一标识 ID
        public string messageID;

        public PushMessage(AndroidJavaObject data = null)
        {
            if (data == null)
            {
                return;
            }

            this.title = data.Call<string>("getTitle");
            this.desc = data.Call<string>("getDesc");
            this.ext = data.Call<string>("getExt");
            this.messageID = data.Call<string>("getMessageID");
        }

        public static PushMessage FromJson(string jsonString)
        {
            if (string.IsNullOrEmpty(jsonString)) return new PushMessage();

            try
            {
                JsonSerializerSettings settings = new JsonSerializerSettings();
                settings.MissingMemberHandling = MissingMemberHandling.Ignore;
                settings.DefaultValueHandling = DefaultValueHandling.Populate;
                PushMessage ret = JsonConvert.DeserializeObject<PushMessage>(jsonString, settings);
                return ret;
            }
            catch (System.Exception error)
            {
                Debug.LogError(error);
            }
            return new PushMessage();
        }
    }
}