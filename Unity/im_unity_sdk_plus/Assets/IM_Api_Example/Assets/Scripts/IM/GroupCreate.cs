using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using UnityEngine.SceneManagement;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System;
using com.tencent.im.unity.demo.utils;

public class GroupCreate : MonoBehaviour
{
  public Text Header;
  public InputField GroupID;
  public InputField GroupName;
  public Dropdown GroupType;
  public Text Result;

  public Button Submit;
  public Button Copy;

  void Start()
  {
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    GroupID = GameObject.Find("GroupID").GetComponent<InputField>();
    GroupName = GameObject.Find("GroupName").GetComponent<InputField>();
    GroupType = GameObject.Find("Dropdown").GetComponent<Dropdown>();
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GroupCreateSDK);
    Copy.onClick.AddListener(CopyText);
    GroupType.interactable = true;
    if (CurrentSceneInfo.info != null)
    {
      Header.text = CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiText;
    }
    foreach (string name in Enum.GetNames(typeof(TIMGroupType)))
    {
      Dropdown.OptionData option = new Dropdown.OptionData();
      option.text = name;
      GroupType.options.Add(option);
    }
  }

  public void GroupCreateSDK()
  {
    print(GroupID.text);
    print(GroupName.text);
    print(GroupType.value);

    CreateGroupParam param = new CreateGroupParam();
    param.create_group_param_group_id = GroupID.text;
    param.create_group_param_group_name = GroupName.text;
    param.create_group_param_group_type = (TIMGroupType)GroupType.value;
    param.create_group_param_add_option = TIMGroupAddOption.kTIMGroupAddOpt_Any;
    param.create_group_param_notification = "create_group_param_notification";
    param.create_group_param_introduction = "create_group_param_introduction";
    param.create_group_param_face_url = "https://yq.sukeni.com/Logo.jpg";
    TIMResult res = TencentIMSDK.GroupCreate(param, Utils.addAsyncStringDataToScreen(GetResult));
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