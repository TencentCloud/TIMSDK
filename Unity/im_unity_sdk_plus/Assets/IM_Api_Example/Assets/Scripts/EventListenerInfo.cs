using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;

using com.tencent.imsdk.unity.native;
using com.tencent.imsdk.unity.utils;
using com.tencent.imsdk.unity.callback;
using com.tencent.imsdk.unity.enums;
using com.tencent.imsdk.unity.types;
using Newtonsoft.Json;
using UnityEngine;
using AOT;
using System.Text;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading;
using System.Reflection;

public static class EventListenerInfo
{
  public class EventInfo
  {
    private string _result;

    public delegate void NotifyPropertyChanged(string data);

    public NotifyPropertyChanged notifyPropertyChanged;
    public string Result
    {
      get { return _result; }
      set
      {
        if (_result != value)
        {
          _result = value;
          Debug.Log(this.notifyPropertyChanged);
          Debug.Log(value);
          if (this.notifyPropertyChanged != null)
          {
            notifyPropertyChanged(value);
          }
        }
      }
    }
  }
  public static Dictionary<string, EventInfo> Info { get; set; } = new Dictionary<string, EventInfo>();
}