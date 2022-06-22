using UnityEngine;
using UnityEngine.UI;
using com.tencent.im.unity.demo.types;
using UnityEngine.SceneManagement;
using com.tencent.imsdk.unity;
using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using EasyUI.Toast;
using com.tencent.im.unity.demo.utils;

public class GetUserInfo : MonoBehaviour
{
  private string data;

  public void GetServerTimeSDK()
  {
    data = "";
    // long time = TencentIMSDK.GetUserInfo();
    // data += time.ToString();
  }

  private void RenderResult()
  {
    GUIStyle tstyle = new GUIStyle(GUI.skin.textField);
    tstyle.wordWrap = true;
    tstyle.richText = true;
    GUI.TextArea(new Rect(10, 200, UnityEngine.Screen.width - 40, 390), data, tstyle);
  }

  private void OnGUI()
  {
    RenderResult();
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}