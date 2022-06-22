using UnityEngine;
using UnityEngine.UI;
using EasyUI.Toast;
using UnityEngine.EventSystems;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.enums;

public class Settings : MonoBehaviour
{
  private string sdkappid { get; set; }
  private string secret { get; set; }
  private string userID { get; set; }
  public InputField Sdkappid;
  public InputField Secret;
  public InputField UserID;

  private void Start()
  {
    Create();
  }

  public void Create()
  {
    // TODO dev only, del in prod
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

  public void Submit()
  {
    PlayerPrefs.SetString("Sdkappid", Sdkappid.text);
    PlayerPrefs.SetString("Secret", Secret.text);
    PlayerPrefs.SetString("UserID", UserID.text);
    Toast.Show("修改成功");
    print("Sdkappid: " + Sdkappid.text + "  Secret: " + Secret.text + "  UserID: " + UserID.text);
    var res = TencentIMSDK.Uninit();
    print($"uninit success {res}");
  }

  public void Reset()
  {
    Sdkappid.text = "";
    Secret.text = "";
    UserID.text = "";
    print("账号：" + Sdkappid.text + "  密码：" + Secret.text + "  UserID: " + UserID.text);
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}