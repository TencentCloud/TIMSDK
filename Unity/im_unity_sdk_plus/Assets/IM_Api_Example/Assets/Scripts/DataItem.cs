using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using com.tencent.im.unity.demo.types;
using UnityEngine.SceneManagement;

public class DataItem : MonoBehaviour, IPointerClickHandler
{
  public Text text;
  public string scene;

  private ItemData item;

  // Start is called before the first frame update
  void Start()
  {

  }

  // Update is called once per frame
  void Update()
  {

  }

  public void OnPointerClick(PointerEventData eventData)
  {
    CurrentSceneInfo.info = item;
    SceneManager.LoadScene(scene);
  }

  public void SetInfo(ItemData data)
  {
    text.text = data.apiText + "   " + data.apiName;
    scene = data.scene;
    item = data;
  }
}