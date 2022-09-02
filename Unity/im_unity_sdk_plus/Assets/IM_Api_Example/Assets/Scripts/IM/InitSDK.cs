using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using com.tencent.im.unity.demo.utils;
using EasyUI.Toast;
public class InitSDK : MonoBehaviour
{
  public Text Header;
  public Text Result;
  public Button Submit;
  public Button Copy;

  void Start()
  {
    Result = GameObject.Find("ResultText").GetComponent<Text>();
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    if (CurrentSceneInfo.info != null)
    {
      Header.text = Utils.IsCn() ? CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName : CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiName;
    }
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Copy.GetComponentInChildren<Text>().text = Utils.t("Copy");
    Submit.onClick.AddListener(Init);
    Copy.onClick.AddListener(CopyText);
  }

  public void Init()
  {
    var sdkappid = PlayerPrefs.GetString("Sdkappid", "");
    SdkConfig sdkConfig = new SdkConfig();

    sdkConfig.sdk_config_config_file_path = Application.persistentDataPath + "/TIM-Config";

    sdkConfig.sdk_config_log_file_path = Application.persistentDataPath + "/TIM-Log";

    if (sdkappid == "")
    {
      Toast.Show("Input sdkappid first");
      return;
    }
    TIMResult res = TencentIMSDK.Init(long.Parse(sdkappid), sdkConfig);
    Result.text = Utils.SynchronizeResult(res);
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