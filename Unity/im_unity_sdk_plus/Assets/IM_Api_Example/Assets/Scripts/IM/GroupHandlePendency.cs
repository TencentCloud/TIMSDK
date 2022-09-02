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
public class GroupHandlePendency : MonoBehaviour
{
  string[] Labels = new string[] { "SelectGroupPendencyLabel", "GroupHandlePendencyMsgLabel", "GroupHandlePendencyLabel" };
  public Text Header;
  public Dropdown SelectedPendency;
  public Toggle IsAccept;
  public InputField Remark;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<GroupPendency> PendencyList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    GroupGetPendencyListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Remark = GameObject.Find("Remark").GetComponent<InputField>();
    SelectedPendency = GameObject.Find("Pendency").GetComponent<Dropdown>();
    IsAccept = GameObject.Find("IsAccept").GetComponent<Toggle>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GroupHandlePendencySDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
  }
  void GetPendencyList(params object[] parameters)
  {
    try
    {
      PendencyList = new List<GroupPendency>();
      SelectedPendency.ClearOptions();
      string text = (string)parameters[1];
      List<GroupPendency> List = Utils.FromJson<GroupPendencyResult>(text).group_pendency_result_pendency_array;
      Dropdown.OptionData option = new Dropdown.OptionData();
      foreach (GroupPendency item in List)
      {
        print(item.group_pendency_group_id);
        PendencyList.Add(item);
        option = new Dropdown.OptionData();
        option.text = item.group_pendency_group_id;
        SelectedPendency.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedPendency.captionText.text = List[SelectedPendency.value].group_pendency_group_id;
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getGroupPendencyListFailed"));
    }
  }

  void GroupGetPendencyListSDK()
  {
    GroupPendencyOption param = new GroupPendencyOption
    {
      group_pendency_option_start_time = 0
    };
    TIMResult res = TencentIMSDK.GroupGetPendencyList(param, Utils.addAsyncStringDataToScreen(GetPendencyList));
    print($"GroupGetPendencyListSDK {res}");
  }

  void GroupHandlePendencySDK()
  {
    if (PendencyList.Count < 1) return;
    print("GroupId: " + PendencyList[SelectedPendency.value].group_pendency_group_id);
    var param = new GroupHandlePendencyParam
    {
      group_handle_pendency_param_is_accept = IsAccept.isOn,
      group_handle_pendency_param_handle_msg = Remark.text,
      group_handle_pendency_param_pendency = PendencyList[SelectedPendency.value],
    };
    TIMResult res = TencentIMSDK.GroupHandlePendency(param, Utils.addAsyncNullDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GetResult(params object[] parameters)
  {
    GroupGetPendencyListSDK();
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