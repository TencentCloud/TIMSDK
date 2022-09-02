//  Main Scene
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using com.tencent.im.unity.demo.types;
using com.tencent.im.unity.demo.config.ApiDataList;
using com.tencent.im.unity.demo.utils;
using com.tencent.imsdk.unity;

/// <summary>
/// 折叠菜单
/// </summary>
public class FoldPanel : MonoBehaviour
{
  [SerializeField]
  private GameObject panelItem; // 折叠Content
  [SerializeField]
  private TitleItem titleItem;
  [SerializeField]
  private DataItem dataItem;

  private Dropdown Language;

  public List<FoldData> dataList;

  private void Start()
  {
    Create();
  }

  void LanguageValueChanged(Dropdown change)
  {
    PlayerPrefs.SetString("Language", $"{Consts.Languages[change.value].name}:{change.value}");
    SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
  }

  public void Create()
  {
    Language = GameObject.Find("Language").GetComponent<Dropdown>();
    foreach (LanguageData item in Consts.Languages)
    {
      var option = new Dropdown.OptionData();
      option.text = item.text;
      Language.options.Add(option);
    }
    string lang = PlayerPrefs.GetString("Language");
    if (!string.IsNullOrEmpty(lang))
    {
      Language.value = int.Parse(lang.Split(':')[1]);
    }
    Language.onValueChanged.AddListener(delegate
    {
      LanguageValueChanged(Language);
    });
    dataList = Utils.FromJson<List<FoldData>>(ApiDataList.ApiDataListStr);
    for (int i = 0; i < dataList.Count; i++)
    {
      // 创建标题
      TitleItem title = Instantiate(titleItem).GetComponent<TitleItem>();
      title.SetTitle(Utils.t(dataList[i].managerName));
      title.transform.SetParent(this.transform);

      // 创建子折叠面板
      GameObject panel = Instantiate(panelItem);
      panel.transform.SetParent(this.transform);
      title.SetFoldPanel(panel);
      panel.SetActive(false);

      // 创建折叠页数据
      for (int j = 0; j < dataList[i].apis.Count; j++)
      {
        DataItem item = Instantiate(dataItem).GetComponent<DataItem>();
        item.transform.SetParent(panel.transform);
        item.SetInfo(dataList[i].apis[j]);
      }
    }
  }
  void OnApplicationQuit()
  {
    TencentIMSDK.Uninit();
  }
}