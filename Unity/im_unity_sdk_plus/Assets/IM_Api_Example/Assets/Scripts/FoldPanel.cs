//  Main Scene
using UnityEngine;
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

  public List<FoldData> dataList;

  private void Start()
  {
    Create();
  }

  public void Create()
  {
    dataList = Utils.FromJson<List<FoldData>>(ApiDataList.ApiDataListStr);
    for (int i = 0; i < dataList.Count; i++)
    {
      // 创建标题
      TitleItem title = Instantiate(titleItem).GetComponent<TitleItem>();
      title.SetTitle(dataList[i].managerName);
      title.transform.SetParent(this.transform);

      // 创建子折叠面板
      GameObject panel = Instantiate(panelItem);
      panel.transform.SetParent(this.transform);
      // 570是折叠页的宽度，30DataItem的高度
      // panel.GetComponent<RectTransform>().sizeDelta = new Vector3(570, 70 * dataList[i].apis.Count);
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