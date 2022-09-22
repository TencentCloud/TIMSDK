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
public class GroupModifyGroupInfo : MonoBehaviour
{
  string[] Labels = new string[] { "GroupIDLabel", "GroupNameLabel", "GroupNotificationLabel", "GroupIntroductionLabel", "GroupFaceURLLabel", "SelectGroupAddOptionLabel", "GroupMaxMemberLabel", "GroupOwnerLabel", "GroupCustomKeyLabel", "GroupCustomValueLabel", "CustomKeyPlaceHolder", "CustomValuePlaceHolder" };
  public Text Header;
  public Dropdown SelectedGroup;
  public InputField Groupname;
  public InputField Notification;
  public InputField Introduction;
  public InputField FaceURL;
  public Dropdown AddPermission;
  public InputField MaxMember;
  public InputField Owner;
  public InputField CustomKey;
  public InputField CustomValue;
  public Text Result;
  public Button Submit;
  public Button Copy;
  List<string> groupIDList;
  void Start()
  {
    foreach (string label in Labels)
    {
      GameObject.Find(label).GetComponent<Text>().text = Utils.t(label);
    }
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    SelectedGroup = GameObject.Find("GroupID").GetComponent<Dropdown>();
    Groupname = GameObject.Find("Groupname").GetComponent<InputField>();
    Notification = GameObject.Find("Notification").GetComponent<InputField>();
    Introduction = GameObject.Find("Introduction").GetComponent<InputField>();
    FaceURL = GameObject.Find("FaceURL").GetComponent<InputField>();
    AddPermission = GameObject.Find("AddPermission").GetComponent<Dropdown>();
    AddPermission.options.Add(new Dropdown.OptionData
    {
      text = ""
    });
    foreach (string name in Enum.GetNames(typeof(TIMGroupAddOption)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      AddPermission.options.Add(option);
    }
    MaxMember = GameObject.Find("MaxMember").GetComponent<InputField>();
    Owner = GameObject.Find("Owner").GetComponent<InputField>();
    CustomKey = GameObject.Find("CustomKey").GetComponent<InputField>();
    CustomValue = GameObject.Find("CustomValue").GetComponent<InputField>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GroupModifyGroupInfoSDK);
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Copy.onClick.AddListener(CopyText);
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    GroupGetJoinedGroupListSDK();
  }

  void GetGroupList(params object[] parameters)
  {
    try
    {
      groupIDList = new List<string>();
      SelectedGroup.ClearOptions();
      string text = (string)parameters[1];
      List<GroupBaseInfo> List = Utils.FromJson<List<GroupBaseInfo>>(text);
      foreach (GroupBaseInfo item in List)
      {
        print(item.group_base_info_group_id);
        groupIDList.Add(item.group_base_info_group_id);
        Dropdown.OptionData option = new Dropdown.OptionData();
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

  void GroupGetJoinedGroupListSDK()
  {
    TIMResult res = TencentIMSDK.GroupGetJoinedGroupList(Utils.addAsyncStringDataToScreen(GetGroupList));
    print($"GroupGetJoinedGroupListSDK {res}");
  }

  void GroupModifyGroupInfoSDK()
  {
    if (groupIDList.Count < 1) return;
    var custom_string_array = new List<GroupInfoCustemString>();
    var keys = CustomKey.text.Split(',');
    var vals = CustomValue.text.Split(',');
    for (int idx = 0; idx < keys.Length; idx++)
    {
      if (!string.IsNullOrEmpty(keys[idx]))
      {
        custom_string_array.Add(new GroupInfoCustemString
        {
          group_info_custom_string_info_key = keys[idx],
          group_info_custom_string_info_value = idx < vals.Length ? vals[idx] : ""
        });
      }
    }
    var param = new GroupModifyInfoParam
    {
      group_modify_info_param_group_id = groupIDList[SelectedGroup.value],
    };
    var flag = TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_None;
    if (!string.IsNullOrEmpty(Groupname.text))
    {
      param.group_modify_info_param_group_name = Groupname.text;
      flag |= TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_Name;
    }
    if (!string.IsNullOrEmpty(Notification.text))
    {
      param.group_modify_info_param_notification = Notification.text;
      flag |= TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_Notification;
    }
    if (!string.IsNullOrEmpty(Introduction.text))
    {
      param.group_modify_info_param_introduction = Introduction.text;
      flag |= TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_Introduction;
    }
    if (!string.IsNullOrEmpty(FaceURL.text))
    {
      param.group_modify_info_param_face_url = FaceURL.text;
      flag |= TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_FaceUrl;
    }
    if (AddPermission.value > 0)
    {
      param.group_modify_info_param_add_option = (TIMGroupAddOption)(AddPermission.value - 1);
      flag |= TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_AddOption;
    }
    if (!string.IsNullOrEmpty(MaxMember.text))
    {
      int maxMember;
      if (!int.TryParse(MaxMember.text, out maxMember))
      {
        Debug.LogError("Input MaxMember is not number!");
        return;
      }
      else if (maxMember < 0)
      {
        Debug.LogError("Input MaxMember can't be negative number!");
        return;
      }
      param.group_modify_info_param_max_member_num = (uint)(maxMember);
      flag |= TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_MaxMmeberNum;
    }
    if (custom_string_array.Count > 0)
    {
      param.group_modify_info_param_custom_info = custom_string_array;
      flag |= TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_Custom;
    }
    if (!string.IsNullOrEmpty(Owner.text))
    {
      param.group_modify_info_param_owner = Owner.text;
      flag |= TIMGroupModifyInfoFlag.kTIMGroupModifyInfoFlag_Owner;
    }
    param.group_modify_info_param_modify_flag = flag;
    print(Utils.ToJson(param));
    TIMResult res = TencentIMSDK.GroupModifyGroupInfo(param, Utils.addAsyncNullDataToScreen(GetResult));
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