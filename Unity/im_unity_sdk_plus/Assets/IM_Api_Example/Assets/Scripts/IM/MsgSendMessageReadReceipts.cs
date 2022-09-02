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
using System.Text;
using System.Collections.Generic;
public class MsgSendMessageReadReceipts : MonoBehaviour
{
  string[] Labels = new string[] { "SelectGroupLabel" };
  public Text Header;
  public Dropdown SelectedGroup;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> GroupList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    GroupGetJoinedGroupListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedGroup = GameObject.Find("Group").GetComponent<Dropdown>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(MsgGetMsgListSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }

  void GetGroupList(params object[] parameters)
  {
    try
    {
      GroupList = new List<string>();
      SelectedGroup.ClearOptions();
      string text = (string)parameters[1];
      List<GroupBaseInfo> List = Utils.FromJson<List<GroupBaseInfo>>(text);
      foreach (GroupBaseInfo item in List)
      {
        print(item.group_base_info_group_id);
        GroupList.Add(item.group_base_info_group_id);
        var option = new Dropdown.OptionData();
        option.text = item.group_base_info_group_id;
        SelectedGroup.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedGroup.captionText.text = List[SelectedGroup.value].group_base_info_group_id;
      }
      else
      {
        SelectedGroup.captionText.text = "";
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupListFailed"));
    }
  }

  void HandleMsgListRes(params object[] parameters)
  {
    try
    {
      string text = (string)parameters[1];
      List<Message> msg_list = Utils.FromJson<List<Message>>(text);
      print($"msg_list: {parameters[1]}");
      MsgSendMessageReadReceiptsSDK(msg_list);
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getMsgListFailed"));
    }
  }

  void MsgGetMsgListSDK()
  {
    var get_message_list_param = new MsgGetMsgListParam
    {
      msg_getmsglist_param_count = 20
    };
    print(GroupList[SelectedGroup.value]);
    TIMResult res = TencentIMSDK.MsgGetMsgList(GroupList[SelectedGroup.value], TIMConvType.kTIMConv_Group, get_message_list_param, Utils.addAsyncStringDataToScreen(HandleMsgListRes));
  }

  void GroupGetJoinedGroupListSDK()
  {
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(Utils.addAsyncStringDataToScreen(GetGroupList));
    print($"GroupGetJoinedGroupListSDK {res}");
  }

  void MsgSendMessageReadReceiptsSDK(List<Message> msg_list)
  {
    print(GroupList[SelectedGroup.value]);
    if (msg_list.Count < 1)
    {
      Toast.Show("No Message Found");
      return;
    }
    TIMResult res = TencentIMSDK.MsgSendMessageReadReceipts(msg_list, Utils.addAsyncNullDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
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