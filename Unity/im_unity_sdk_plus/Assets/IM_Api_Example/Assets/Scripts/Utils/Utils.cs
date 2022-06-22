using System;
using UnityEngine;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using com.tencent.imsdk.unity.enums;
using com.tencent.imsdk.unity.callback;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

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
  }
}