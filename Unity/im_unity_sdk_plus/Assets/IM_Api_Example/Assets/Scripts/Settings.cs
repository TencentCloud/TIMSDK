using UnityEngine;
using UnityEngine.UI;
using EasyUI.Toast;
using UnityEngine.EventSystems;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.enums;
using com.tencent.im.unity.demo.utils;

public class Settings : MonoBehaviour
{
  private string sdkappid { get; set; }
  private string secret { get; set; }
  private string userID { get; set; }
  public Text Header;
  public InputField Sdkappid;
  public InputField Secret;
  public InputField UserID;
  public Button Submit;
  public Button Reset;

  private void Start()
  {
    Create();
  }

  public void Create()
  {
    Header = GameObject.Find("HeaderText").GetComponent<Text>();
    Submit = GameObject.Find("Submit").GetComponent<Button>();
    Reset = GameObject.Find("Reset").GetComponent<Button>();
    Header.text = Utils.t("Config");
    Submit.GetComponentInChildren<Text>().text = Utils.t("Confirm");
    Reset.GetComponentInChildren<Text>().text = Utils.t("Reset");
    Submit.onClick.AddListener(OnSubmit);
    Reset.onClick.AddListener(OnReset);
    sdkappid = PlayerPrefs.GetString("Sdkappid", ImConfigs.sdkappid);
    secret = PlayerPrefs.GetString("Secret", ImConfigs.user_sig);
    userID = PlayerPrefs.GetString("UserID", ImConfigs.user_id);
    Sdkappid = GameObject.Find("Sdkappid").GetComponent<InputField>();
    Secret = GameObject.Find("Secret").GetComponent<InputField>();
    UserID = GameObject.Find("UserID").GetComponent<InputField>();
    Sdkappid.text = sdkappid;
    Secret.text = secret;
    UserID.text = userID;
  }

  public void OnSubmit()
  {
    PlayerPrefs.SetString("Sdkappid", Sdkappid.text);
    PlayerPrefs.SetString("Secret", Secret.text);
    PlayerPrefs.SetString("UserID", UserID.text);
    Toast.Show(Utils.t("Modify Successfully"));
    print("Sdkappid: " + Sdkappid.text + "  Secret: " + Secret.text + "  UserID: " + UserID.text);
    var res = TencentIMSDK.Uninit();
    print($"uninit success {res}");
  }

  public void OnReset()
  {
    Sdkappid.text = "";
    Secret.text = "";
    UserID.text = "";
    print("Sdkappid：" + Sdkappid.text + "  UserSig：" + Secret.text + "  UserID: " + UserID.text);
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}