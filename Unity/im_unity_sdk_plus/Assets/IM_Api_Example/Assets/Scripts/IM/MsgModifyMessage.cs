using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System;
using com.tencent.im.unity.demo.utils;
using System.Text;
using EasyUI.Toast;
using System.Collections;
using System.Collections.Generic;
public class MsgModifyMessage : MonoBehaviour
{
  public Text Header;
  public Dropdown SelectedConv;
  public Dropdown SelectedMsg;
  public Text Result;
  public Button Submit;
  public Button Copy;
  public Toggle PinToggle;
  public InputField Input;
  private List<ConvInfo> ConvList;
  private List<Message> MsgList;
  void Start()
  {
    GameObject.Find("SelectConvLabel").GetComponent<Text>().text = Utils.t("SelectConvLabel");
    GameObject.Find("SelectMsgLabel").GetComponent<Text>().text = Utils.t("SelectMsgLabel");
    GameObject.Find("MessageLabel").GetComponent<Text>().text = Utils.t("MessageLabel");
    ConvGetConvListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedConv = GameObject.Find("Dropdown").GetComponent<Dropdown>();
    SelectedMsg = GameObject.Find("MsgDropdown").GetComponent<Dropdown>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Input = GameObject.Find("Message").GetComponent<InputField>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(MsgModifyMessageSDK);
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
        if (item.conv_type == TIMConvType.kTIMConv_Group)
        {
          print(item.conv_id);
          ConvList.Add(item);
          Dropdown.OptionData option = new Dropdown.OptionData();
          option.text = item.conv_id;
          SelectedConv.options.Add(option);
        }
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
        print(item.message_msg_id);
        MsgList.Add(item);
        Dropdown.OptionData option = new Dropdown.OptionData();
        option.text = item.message_msg_id;
        SelectedMsg.options.Add(option);
      }
      if (ListRes.Count > 0)
      {
        SelectedMsg.captionText.text = ListRes[SelectedMsg.value].message_msg_id;
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

  void MsgModifyMessageSDK()
  {
    if (ConvList.Count < 1 || MsgList.Count < 1) return;
    var conv_id = ConvList[SelectedConv.value].conv_id;
    print(conv_id);
    Message msg = MsgList[SelectedMsg.value];
    msg.message_cloud_custom_str = "unity local text modified data";
    msg.message_elem_array = new List<Elem>{new Elem
      {
        elem_type = TIMElemType.kTIMElem_Text,
        text_elem_content = Input.text
      }};
    foreach (Elem elem in msg.message_elem_array)
    {
      if (elem.elem_type == TIMElemType.kTIMElem_Text)
      {
        elem.text_elem_content = Input.text;
        break;
      }
    }
    // 变更条件：
    // 1. 增强版 6.2.2363 及以上版本支持
    // 2. 消息类型：V2TIMTextElem, V2TIMCustomElem, V2TIMLocationElem, V2TIMFaceElem
    // 3. 只支持群组消息变更
    TIMResult res = TencentIMSDK.MsgModifyMessage(msg, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GetResult(params object[] parameters)
  {
    // GroupDropdownValueChanged(SelectedConv);
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