using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.EventSystems;
using Newtonsoft.Json;
using TMPro;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using Object = System.Object;


public static class MyUtils
{

    public static IEnumerator Post(string reqUrl, Object req, Action<LoginInfo, string> callBack, LoginInfo loginInfo)
    {
        Debug.Log($"Post Url: {reqUrl}");

        var jsonParam = JsonConvert.SerializeObject(req);

        var postData = System.Text.Encoding.UTF8.GetBytes(jsonParam);

        var webRequest = new UnityWebRequest(reqUrl, UnityWebRequest.kHttpVerbPOST);
        webRequest.uploadHandler = new UploadHandlerRaw(postData);
        webRequest.downloadHandler = new DownloadHandlerBuffer();
        webRequest.uploadHandler.contentType = "application/json";
        webRequest.SetRequestHeader("Content-Type", "application/json");
        webRequest.SetRequestHeader("Accept", "application/json");

        yield return webRequest.SendWebRequest();

        if (webRequest.result == UnityWebRequest.Result.ProtocolError ||
            webRequest.result == UnityWebRequest.Result.ConnectionError)
        {
            Debug.LogError(webRequest.error);
        }
        else
        {
            var resStr = webRequest.downloadHandler.text;
            Debug.Log(resStr);

            callBack?.Invoke(loginInfo, resStr);
        }

        webRequest.Dispose();
    }

    // Start is called before the first frame update
    #region LoginInfo

    public static void StoreLoginInfo(string channel, string uid, string csrf, string pid)
    {
        PlayerPrefs.SetString("channel", channel); //bili or guest
        PlayerPrefs.SetString("uid", uid);
        PlayerPrefs.SetString("csrf", csrf);
        PlayerPrefs.SetString("pid", pid);

        Debug.Log($"Store Login Info: channel: {channel}, uid: {uid}, csrf: {csrf}, pid: {pid}");
    }

    public static void ClearLoginInfo()
    {
        PlayerPrefs.DeleteKey("channel"); //bili or guest
        PlayerPrefs.DeleteKey("uid");
        PlayerPrefs.DeleteKey("csrf");
        PlayerPrefs.DeleteKey("pid");

        Debug.Log("ClearLoginInfo");
    }


    public static List<string> GetLoginInfo()
    {
        List<string> localInfo = new List<string>();
        localInfo.Add(PlayerPrefs.GetString("channel"));
        localInfo.Add(PlayerPrefs.GetString("uid"));
        localInfo.Add(PlayerPrefs.GetString("csrf"));
        localInfo.Add(PlayerPrefs.GetString("pid"));

        Debug.Log($"Load Login Info: channel: {localInfo[0]}, uid: {localInfo[1]}, csrf:{localInfo[2]}, pid: {localInfo[3]}");
        return localInfo;
    }

    public static bool IsExistLocalInfo()
    {
        if (!PlayerPrefs.HasKey("uid") || !PlayerPrefs.HasKey("csrf") || !PlayerPrefs.HasKey("pid"))
            return false;

        // long.TryParse(PlayerPrefs.GetString("uid"), out var uid);
        return true;
    }
    #endregion
}