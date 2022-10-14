using System;
using UnityEngine;
using System.Runtime.InteropServices;
using System.Diagnostics;
using Newtonsoft.Json;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System.Collections;
using System.Collections.Generic;

namespace com.tencent.imsdk.unity.utils
{
    public class Utils
    {

        private static int randomIndex = 1;
        public static void Log(string s)
        {
            UnityEngine.Debug.Log("TencentIMSDK：" + s);
        }
        public static IntPtr string2intptr(string str)
        {
            if(str ==null){

                return Marshal.StringToHGlobalAnsi("");
            }
            return Marshal.StringToHGlobalAnsi(str);
        }
        public static string intptr2string(IntPtr ptr)
        {
            if(ptr == null){
                return "";
            }
            return Marshal.PtrToStringAnsi(ptr) ?? "";
        }
        public static string getRandomStr()
        {
            return "KeyString_" + randomIndex++;
        }
        public static T FromJson<T>(string pJson)
        {
            if (typeof(T) == typeof(string)) {
                return (T)(object) pJson;
            }
            if (string.IsNullOrEmpty(pJson)) return default(T);
            try
            {
                JsonSerializerSettings settings = new JsonSerializerSettings();
                settings.MissingMemberHandling = MissingMemberHandling.Ignore;
                T ret = JsonConvert.DeserializeObject<T>(pJson, settings);
                return ret;
            }
            catch (System.Exception error)
            {
                UnityEngine.Debug.LogError(error);
            }
            return default(T);
        }
        public static long GetTimeStamp()
        {
            TimeSpan ts = DateTime.Now - new DateTime(1970, 1, 1, 0, 0, 0, 0);
            return Convert.ToInt64(ts.TotalMilliseconds);
        }
        public static string ToJson(object pData)
        {
            
            try
            {
                var setting = new JsonSerializerSettings();
                setting.NullValueHandling = NullValueHandling.Ignore;
                string data = JsonConvert.SerializeObject(pData, setting);
                return data;
            }
            catch (System.Exception error)
            {
                UnityEngine.Debug.LogError(error);
            }
            
            return null;
        }
        public static void LoadMessage(){
            Message message = new Message();
            message.message_client_time = (ulong)Utils.GetTimeStamp();
            message.message_cloud_custom_str = "some str";
            message.message_conv_id = "some conv_id";
            message.message_conv_type = TIMConvType.kTIMConv_C2C;
            message.message_custom_int = 0;
            message.message_custom_str = "some str";
            message.message_excluded_from_last_message = false;
            message.message_group_at_user_array = new List<String>(){
                "userid"
            };
            message.message_group_receipt_read_count = 0;
            message.message_group_receipt_unread_count = 0;
            message.message_has_sent_receipt = true;
            message.message_version = (ulong)Utils.GetTimeStamp();
            message.message_unique_id = (ulong)Utils.GetTimeStamp();
            message.message_target_group_member_array = new List<String>(){
                "userid"
            };
            message.message_status = TIMMsgStatus.kTIMMsg_SendSucc;
            message.message_seq = (ulong)Utils.GetTimeStamp();
            message.message_sender_profile = new UserProfile(){
                user_profile_birthday = 0
            };
            message.message_elem_array = new List<Elem>(){
                new Elem(){
                    elem_type = TIMElemType.kTIMElem_Text,
                    text_elem_content = "",
                }
            };
            Utils.FromJson<Message>(Utils.ToJson(message));
        }
    }
}