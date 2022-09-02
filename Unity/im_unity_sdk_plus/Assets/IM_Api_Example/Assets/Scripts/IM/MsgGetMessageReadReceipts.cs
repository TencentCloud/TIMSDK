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
public class MsgGetMessageReadReceipts : MonoBehaviour
{
  public Text Header;
  public Dropdown SelectedConv;
  public Dropdown SelectedMsg;
  public Text Result;
  public Button Submit;
  public Button Copy;
  public Toggle PinToggle;
  private List<ConvInfo> ConvList;
  private List<Message> MsgList;
  void Start()
  {
    GameObject.Find("SelectConvLabel").GetComponent<Text>().text = Utils.t("SelectConvLabel");
    GameObject.Find("SelectMsgLabel").GetComponent<Text>().text = Utils.t("SelectMsgLabel");
    ConvGetConvListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedConv = GameObject.Find("Dropdown").GetComponent<Dropdown>();
    SelectedMsg = GameObject.Find("MsgDropdown").GetComponent<Dropdown>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(MsgGetMessageReadReceiptsSDK);
    Copy.onClick.AddListener(CopyText);
    SelectedConv.interactable = true;
    SelectedConv.onValueChanged.AddListener(delegate
    {
      GroupDropdownValueChanged(SelectedConv);
    });
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void GroupDropdownValueChanged(Dropdown change)
  {
    SelectedMsg.captionText.text = "";
    SelectedMsg.ClearOptions();
    SelectedMsg.value = 0;
    MsgList = new List<Message>();
    if (ConvList.Count > 0)
    {
      string conv_id = ConvList[change.value].conv_id;
      TIMConvType conv_type = ConvList[change.value].conv_type;
      MsgGetMsgListSDK(conv_id, conv_type);
    }
  }

  void GetConvList(params object[] parameters)
  {
    try
    {
      ConvList = new List<ConvInfo>();
      SelectedConv.ClearOptions();
      string text = (string)parameters[1];
      List<ConvInfo> List = Utils.FromJson<List<ConvInfo>>(text);
      foreach (ConvInfo item in List)
      {
        print(item.conv_id);
        ConvList.Add(item);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.conv_id;
        SelectedConv.options.Add(option);
      }
      if (ConvList.Count > 0)
      {
        SelectedConv.captionText.text = ConvList[SelectedConv.value].conv_id;
        GroupDropdownValueChanged(SelectedConv);
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getConvListFailed"));
    }
  }

  void GetMsgList(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      List<Message> ListRes = Utils.FromJson<List<Message>>(text);
      foreach (Message item in ListRes)
      {
        if ((item.message_is_from_self == true) && (item.message_need_read_receipt == true))
        {
          print(item.message_msg_id);
          MsgList.Add(item);
          Dropdown.OptionData optionMsg = new Dropdown.OptionData();
          optionMsg.text = item.message_msg_id;
          SelectedMsg.options.Add(optionMsg);
        }
      }
      if (MsgList.Count > 0)
      {
        SelectedMsg.captionText.text = MsgList[SelectedMsg.value].message_msg_id;
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getMsgListFailed"));
    }
  }

  void ConvGetConvListSDK()
  {
    TIMResult res = TencentIMSDK.ConvGetConvList(Utils.addAsyncStringDataToScreen(GetConvList));
    print($"ConvGetConvListSDK {res}");
  }

  void MsgGetMsgListSDK(string conv_id, TIMConvType conv_type)
  {
    var get_message_list_param = new MsgGetMsgListParam
    {
      msg_getmsglist_param_count = 20
    };
    print(conv_id + conv_type);
    TIMResult res = TencentIMSDK.MsgGetMsgList(conv_id, conv_type, get_message_list_param, Utils.addAsyncStringDataToScreen(GetMsgList));
  }

  void MsgGetMessageReadReceiptsSDK()
  {
    if (SelectedMsg.value > -1 && SelectedMsg.value < MsgList.Count)
    {
      print("Selected Message: " + MsgList[SelectedMsg.value].message_msg_id);
      var list = new List<Message> {
      MsgList[SelectedMsg.value]
    };
      TIMResult res = TencentIMSDK.MsgGetMessageReadReceipts(list, Utils.addAsyncStringDataToScreen(GetResult));
      Result.text = Utils.SynchronizeResult(res);
    }
  }

  void GetResult(params object[] parameters)
  {
    Result.text += (string)parameters[0];
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