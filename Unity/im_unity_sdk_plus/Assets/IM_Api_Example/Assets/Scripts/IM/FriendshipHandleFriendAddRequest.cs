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
public class FriendshipHandleFriendAddRequest : MonoBehaviour
{
  string[] Labels = new string[] { "FriendIDLabel", "FriendRemarkLabel", "FriendGroupLabel", "FriendResponseActionLabel" };
  public Text Header;
  public Dropdown SelectedPendency;
  public Dropdown SelectedAction;
  public InputField Remark;
  public InputField Group;
  public Text Result;
  public Button Submit;
  public Button Copy;
  private List<string> PendencyList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    FriendshipGetPendencyListSDK();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Remark = GameObject.Find("Remark").GetComponent<InputField>();
    Group = GameObject.Find("Group").GetComponent<InputField>();
    SelectedPendency = GameObject.Find("Pendency").GetComponent<Dropdown>();
    SelectedAction = GameObject.Find("Action").GetComponent<Dropdown>();
    foreach (string name in Enum.GetNames(typeof(TIMFriendResponseAction)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      SelectedAction.options.Add(option);
    }
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(FriendshipHandleFriendAddRequestSDK);
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
      PendencyList = new List<string>();
      SelectedPendency.ClearOptions();
      string text = (string)parameters[1];
      List<FriendAddPendencyInfo> List = Utils.FromJson<PendencyPage>(text).pendency_page_pendency_info_array;
      Dropdown.OptionData option = new Dropdown.OptionData();
      foreach (FriendAddPendencyInfo item in List)
      {
        print(item.friend_add_pendency_info_idenitifer);
        PendencyList.Add(item.friend_add_pendency_info_idenitifer);
        option = new Dropdown.OptionData();
        option.text = item.friend_add_pendency_info_idenitifer;
        SelectedPendency.options.Add(option);
      }
      if (List.Count > 0)
      {
        SelectedPendency.captionText.text = List[SelectedPendency.value].friend_add_pendency_info_idenitifer;
      }
    }
    catch (Exception ex)
    {
      Toast.Show(Utils.t("getPendencyListFailed"));
    }
  }

  void FriendshipGetPendencyListSDK()
  {
    FriendshipGetPendencyListParam param = new FriendshipGetPendencyListParam
    {
      friendship_get_pendency_list_param_type = TIMFriendPendencyType.FriendPendencyTypeComeIn
    };
    TIMResult res = TencentIMSDK.FriendshipGetPendencyList(param, Utils.addAsyncStringDataToScreen(GetPendencyList));
    print($"FriendshipGetPendencyListSDK {res}");
  }

  void FriendshipHandleFriendAddRequestSDK()
  {
    if (PendencyList.Count < 1) return;
    print("UserId: " + PendencyList[SelectedPendency.value]);
    var param = new FriendResponse
    {
      friend_respone_identifier = PendencyList[SelectedPendency.value],
      friend_respone_action = (TIMFriendResponseAction)SelectedAction.value,
      friend_respone_remark = Remark.text,
      friend_respone_group_name = Group.text
    };
    TIMResult res = TencentIMSDK.FriendshipHandleFriendAddRequest(param, Utils.addAsyncStringDataToScreen(GetResult));
    Result.text = Utils.SynchronizeResult(res);
  }

  void GetResult(params object[] parameters)
  {
    FriendshipGetPendencyListSDK();
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