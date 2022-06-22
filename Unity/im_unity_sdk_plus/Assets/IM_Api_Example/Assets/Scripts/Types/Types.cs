using System.Collections;
using System.Collections.Generic;
namespace com.tencent.im.unity.demo.types
{
  [System.Serializable]
  public class FoldData
  {
    public string apiManager { get; set; }
    public string managerName { get; set; }
    public List<ItemData> apis { get; set; }
  }

  [System.Serializable]
  public class ItemData
  {
    public string apiName { get; set; }
    public string apiText { get; set; }
    public string apiDesc { get; set; }
    public string scene { get; set; }
  }
  [System.Serializable]
  public class EventListenerData
  {
    public string eventName { get; set; }
    public string eventText { get; set; }
    public string eventDesc { get; set; }
  }
}