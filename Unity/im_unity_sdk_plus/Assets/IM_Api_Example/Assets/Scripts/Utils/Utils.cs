using System;
using UnityEngine;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using com.tencent.imsdk.unity.enums;
using com.tencent.imsdk.unity.callback;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using com.tencent.im.unity.demo.types;

namespace com.tencent.im.unity.demo.utils
{
  public class Utils
  {
    public static string SynchronizeResult(TIMResult res)
    {
      return "Synchronize return: " + ((int)res).ToString();
    }
    public static ValueCallback<string> addAsyncStringDataToScreen(Callback cb)
    {
      var callback = cb;
      return (int code, string desc, string callbackData, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""code"":" + code.ToString() + @",""desc"":""" + desc + @""",""json_param"":" + (string.IsNullOrEmpty(callbackData) ? "null" : callbackData) + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(head + formatted, callbackData);
    };
    }
    public static NullValueCallback addAsyncNullDataToScreen(Callback cb)
    {
      var callback = cb;
      return (int code, string desc, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""code"":" + code.ToString() + @",""desc"":""" + desc + @""",""json_param"":" + "null" + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(head + formatted);
    };
    }
    public delegate void Callback(params string[] parameters);

    public static MsgGroupMessageReadMemberListStringCallback SetMsgGroupMessageReadMemberListCallback(Callback cb)
    {
      var callback = cb;
      return (string json_group_member_array, ulong next_seq, bool is_finished, string user_data) =>
        {
          string head = "\n" + user_data + "Asynchronous return:\n\n";
          string body = @"{""json_group_member_array"":" + json_group_member_array + "}";
          JObject json = JObject.Parse(body);
          string formatted = SyntaxHighlightJson(json.ToString());
          callback(head + formatted, json_group_member_array, next_seq.ToString(), is_finished.ToString());
        };
    }

    // EventCallback  ...

    public static RecvNewMsgStringCallback RecvNewMsgCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string message, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""message"":" + (string.IsNullOrEmpty(message) ? "null" : message) + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted, message);
    };
    }

    public static MsgReadedReceiptStringCallback SetMsgReadedReceiptCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string message_receipt, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""message_receipt"":" + (string.IsNullOrEmpty(message_receipt) ? "null" : message_receipt) + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted, message_receipt);
    };
    }
    public static MsgRevokeStringCallback SetMsgRevokeCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string msg_locator, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""msg_locator"":" + (string.IsNullOrEmpty(msg_locator) ? "null" : msg_locator) + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted, msg_locator);
    };
    }
    public static GroupTipsEventStringCallback SetGroupTipsEventCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string json_group_tip_array, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""json_group_tip_array"":" + (string.IsNullOrEmpty(json_group_tip_array) ? "null" : json_group_tip_array) + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted, json_group_tip_array);
    };
    }
    public static MsgElemUploadProgressStringCallback SetMsgElemUploadProgressCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string message, int index, int cur_size, int total_size, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""message"":" + (string.IsNullOrEmpty(message) ? "null" : message) + @",""index"":""" + index + @",""cur_size"":""" + cur_size + @",""total_size"":""" + total_size + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted, message);
    };
    }
    public static GroupAttributeChangedStringCallback SetGroupAttributeChangedCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string group_id, string group_attributes, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""group_id"":" + group_id + @"{""group_attributes"":" + (string.IsNullOrEmpty(group_attributes) ? "null" : group_attributes) + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static ConvEventStringCallback SetConvEventCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (TIMConvEvent conv_event, string conv_list, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""conv_event"":""" + conv_event + @""",""conv_list"":" + (string.IsNullOrEmpty(conv_list) ? "null" : conv_list) + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static ConvTotalUnreadMessageCountChangedCallback SetConvTotalUnreadMessageCountChangedCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (int total_unread_count, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""total_unread_count"":" + total_unread_count + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static NetworkStatusListenerCallback SetNetworkStatusListenerCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (TIMNetworkStatus status, int code, string desc, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""status"":""" + status + @""",""code"":" + code + @",""desc"":""" + desc + @"""}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static KickedOfflineCallback SetKickedOfflineCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      callback(eventInfo, head);
    };
    }
    public static UserSigExpiredCallback SetUserSigExpiredCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      callback(eventInfo, head);
    };
    }
    public static OnAddFriendStringCallback SetOnAddFriendCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string userids, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""user_ids"":" + userids + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static OnDeleteFriendStringCallback SetOnDeleteFriendCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string userids, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""user_ids"":" + userids + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static UpdateFriendProfileStringCallback SetUpdateFriendProfileCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string friend_profile_update_array, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""friend_profile_update_array"":" + friend_profile_update_array + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static FriendAddRequestStringCallback SetFriendAddRequestCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string friend_add_request_pendency_array, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""friend_add_request_pendency_array"":" + friend_add_request_pendency_array + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static FriendApplicationListDeletedStringCallback SetFriendApplicationListDeletedCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string userids, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""user_ids"":" + userids + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static FriendApplicationListReadCallback SetFriendApplicationListReadCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      callback(eventInfo, head);
    };
    }
    public static FriendBlackListAddedStringCallback SetFriendBlackListAddedCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string friend_black_added_array, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""friend_black_added_array"":" + friend_black_added_array + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public static FriendBlackListDeletedStringCallback SetFriendBlackListDeletedCallback(EventCallback cb, EventListenerInfo.EventInfo eventInfo)
    {
      var callback = cb;
      return (string userids, string user_data) =>
    {
      string head = "\n" + user_data + "Asynchronous return:\n\n";
      string body = @"{""user_ids"":" + userids + "}";
      JObject json = JObject.Parse(body);
      string formatted = SyntaxHighlightJson(json.ToString());
      callback(eventInfo, head + formatted);
    };
    }
    public delegate void EventCallback(EventListenerInfo.EventInfo eventInfo, params string[] parameters);

    public static string PrefixEventCallbackData(string eventName, string data)
    {
      return "<color=\"#757575\">" + $"//{eventName}" + "</color>\n\n" + data;
    }
    public static string SyntaxHighlightJson(string original)
    {
      // From http://joelabrahamsson.com/syntax-highlighting-json-with-c/
      // ¤ = Placeholder for " which gets replaced at the end, avoids needing to escape "
      return Regex.Replace(
        original,
        @"(¤(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\¤])*¤(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)".Replace('¤', '"'),
        match =>
        {
          var cls = "55b6c9"; // number
          if (Regex.IsMatch(match.Value, @"^¤".Replace('¤', '"')))
          {
            if (Regex.IsMatch(match.Value, ":$"))
            {
              cls = "e9de8e"; // key
            }
            else
            {
              cls = "e9de8e"; // string
            }
          }
          else if (Regex.IsMatch(match.Value, "true|false"))
          {
            cls = "ce466f"; // boolean
          }
          else if (Regex.IsMatch(match.Value, "null"))
          {
            cls = "ce466f"; // null
          }
          return "<color=\"#" + cls + "\">" + match + "</color>";
        });
    }
    public static string ToJson(object pData)
    {
      try
      {
        var setting = new JsonSerializerSettings();
        setting.NullValueHandling = NullValueHandling.Ignore;

        return Newtonsoft.Json.JsonConvert.SerializeObject(pData, setting);
      }
      catch (System.Exception error)
      {
        Debug.LogError(error);
      }
      return null;
    }
    public static T FromJson<T>(string pJson)
    {
      if (typeof(T) == typeof(string))
      {
        return (T)(object)pJson;
      }
      if (string.IsNullOrEmpty(pJson)) return default(T);
      try
      {
        JsonSerializerSettings settings = new JsonSerializerSettings();
        settings.MissingMemberHandling = MissingMemberHandling.Ignore;
        T ret = Newtonsoft.Json.JsonConvert.DeserializeObject<T>(pJson, settings);
        return ret;
      }
      catch (System.Exception error)
      {
        Debug.LogError(error);
      }
      return default(T);
    }
    public static void Copy(string text)
    {
      TextEditor editor = new TextEditor();
      editor.text = text;
      editor.SelectAll();
      editor.Copy();
    }

    public static bool IsCn()
    {
      string lang = PlayerPrefs.GetString("Language", "cn:0");
      return lang.StartsWith("cn");
    }

    public static string t(string key)
    {
      string lang = PlayerPrefs.GetString("Language", "cn:0").Split(':')[0];
      if (I18n.dict.TryGetValue(key, out I18nData i18nData))
      {
        switch (lang)
        {
          case "cn": return i18nData.cn;
          case "en": return i18nData.en ?? key;
          default: return i18nData.en ?? key;
        }
      }
      return key;
    }

    public delegate void PickFileCallback(string path);

    public static void PickImage(PickFileCallback cb)
    {
      NativeGallery.Permission permission = NativeGallery.GetImageFromGallery((path) =>
      {
        Debug.Log("Image path: " + path);
        if (path != null)
        {
          cb(path);
          // Create Texture from selected image
          // Texture2D texture = NativeGallery.LoadImageAtPath(path, maxSize);
        }
      });

      Debug.Log("Permission result: " + permission);
    }
    public static void PickVideo(PickFileCallback cb)
    {
      NativeGallery.Permission permission = NativeGallery.GetVideoFromGallery((path) =>
      {
        Debug.Log("Video path: " + path);
        if (path != null)
        {
          cb(path);
        }
      });

      Debug.Log("Permission result: " + permission);
    }
    public static void PickFile(PickFileCallback cb)
    {
      string[] allowedFileTypes = new string[] { "*" };
      NativeFilePicker.Permission permission = NativeFilePicker.PickFile((path) =>
      {
        Debug.Log("File path: " + path);
        if (path != null)
        {
          cb(path);
        }
      }, allowedFileTypes);

      Debug.Log("Permission result: " + permission);
    }
  }
}