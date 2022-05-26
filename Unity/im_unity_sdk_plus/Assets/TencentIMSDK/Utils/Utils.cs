using System;
using UnityEngine;
using System.Runtime.InteropServices;
using Newtonsoft.Json;

namespace com.tencent.imsdk.unity.utils
{
    public class Utils
    {

        private static int randomIndex = 1;
        public static void Log(string s)
        {
            Debug.Log("TencentIMSDK：" + s);
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
            return Marshal.PtrToStringAnsi(ptr);
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
                T ret = Newtonsoft.Json.JsonConvert.DeserializeObject<T>(pJson, settings);
                return ret;
            }
            catch (System.Exception error)
            {
                Debug.LogError(error);
            }
            return default(T);
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
    }
}