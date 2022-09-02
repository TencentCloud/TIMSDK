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
public class FriendshipGetPendencyList : MonoBehaviour
{
  public Text Header;
  public Dropdown SelectedFriendPendencyType;
  public Text LastSeq;
  public Text Result;
  public Button Submit;
  public Button Copy;
  string[] Labels = new string[] { "SelectFriendPendencyTypeLabel" };
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedFriendPendencyType = GameObject.Find("Dropdown").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMFriendPendencyType)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedFriendPendencyType.options.Add(option);
    }
    LastSeq = GameObject.Find("LastSeq").GetComponent<Text>();
    LastSeq.text = "0";
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(FriendshipGetPendencyListSDK);
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void FriendshipGetPendencyListSDK()
  {
    FriendshipGetPendencyListParam param = new FriendshipGetPendencyListParam
    {
      friendship_get_pendency_list_param_type = (TIMFriendPendencyType)SelectedFriendPendencyType.value,
      friendship_get_pendency_list_param_start_seq = Convert.ToUInt64(LastSeq.text),
      friendship_get_pendency_list_param_limited_size = 20
    };
    TIMResult res = TencentIMSDK.FriendshipGetPendencyList(param, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GetResult(params object[] parameters)
  {
    Result.text += (string)parameters[0];
    string text = (string)parameters[1];
    var res = Utils.FromJson<PendencyPage>(text);
    LastSeq.text = res.pendency_page_current_seq.ToString();
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