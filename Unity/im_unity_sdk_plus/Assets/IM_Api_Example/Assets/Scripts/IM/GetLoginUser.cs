using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using EasyUI.Toast;
using com.tencent.im.unity.demo.utils;
using System.Text;

public class GetLoginUser : MonoBehaviour
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
      Header.text = CurrentSceneInfo.info.apiText + " " + CurrentSceneInfo.info.apiName;
      Submit.GetComponentInChildren<Text>().text = CurrentSceneInfo.info.apiText;
    }
    Copy = GameObject.Find("Copy").GetComponent<Button>();
    Submit.onClick.AddListener(GetLoginUserSDK);
    Copy.onClick.AddListener(CopyText);
  }

  public void GetLoginUserSDK()
  {
    StringBuilder userId = new StringBuilder(128);
    TIMResult res = TencentIMSDK.GetLoginUserID(userId);
    Result.text = Utils.SynchronizeResult(res);
    Result.text += "\nLoginUser: " + userId.ToString();
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