using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System;
using com.tencent.im.unity.demo.utils;
using EasyUI.Toast;
using System.Collections;
using System.Collections.Generic;
public class GroupGetPendencyList : MonoBehaviour
{
  public Text Header;
  public Text LastSeq;
  public Text Result;
  public Button Submit;
  public Button Copy;
  void Start()
  {
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    LastSeq = GameObject.Find("LastSeq").GetComponent<Text>();
    LastSeq.text = "0";
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(GroupGetPendencyListSDK);
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void GroupGetPendencyListSDK()
  {
    GroupPendencyOption param = new GroupPendencyOption
    {
      group_pendency_option_start_time = Convert.ToUInt64(LastSeq.text)
    };
    TIMResult res = TencentIMSDK.GroupGetPendencyList(param, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GetResult(params object[] parameters)
  {
    Result.text += (string)parameters[0];
    string text = (string)parameters[1];
    var res = Utils.FromJson<GroupPendencyResult>(text);
    LastSeq.text = res.group_pendency_result_next_start_time.ToString();
  }

  void CopyText()
  {
    Utils.Copy(Result.text);
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}