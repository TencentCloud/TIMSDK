using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using DG.Tweening;
public class TitleItem : MonoBehaviour, IPointerClickHandler
{
  [SerializeField]
  private Transform content;
  [SerializeField]
  private Text title;
  [SerializeField]
  private Transform arrow;

  public bool isFold = true;  // 是否是折叠状态
  public Transform foldPanel;

  void Start()
  {
    content.DOScaleY(1, 0.1f);
    content.DOScaleZ(1, 0.1f);
    content.DOScaleX(1, 0.1f);
  }

  public void OnPointerClick(PointerEventData eventData)
  {
    if (isFold)
    {
      isFold = false;

      arrow.DORotate(Vector3.zero, 0.1f);

      if (foldPanel != null)
      {
        foldPanel.gameObject.SetActive(true);
        foldPanel.DOScaleY(1, 0.1f);
        foldPanel.DOScaleZ(1, 0.1f);
        foldPanel.DOScaleX(1, 0.1f);
      }
    }
    else
    {
      isFold = true;
      arrow.DORotate(new Vector3(0, 0, 90), 0.1f);
      if (foldPanel != null)
      {
        foldPanel.DOScaleY(0, 0.1f).OnComplete(() => { foldPanel.gameObject.SetActive(false); });
      }
    }
  }

  public void SetTitle(string _titleName)
  {
    title.text = _titleName;
  }

  public void SetFoldPanel(GameObject panel)
  {
    foldPanel = panel.transform;
  }
}