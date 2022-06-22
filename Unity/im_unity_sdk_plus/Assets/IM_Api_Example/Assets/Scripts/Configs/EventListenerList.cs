namespace com.tencent.im.unity.demo.config.EventListenerList
{
  public static class EventListenerList
  {
    public static string EventListenerListStr = @"[
      {
        ""eventName"": ""AddRecvNewMsgCallback"",
        ""eventText"": ""收到新消息回调"",
        ""eventDesc"": ""注册收到新消息回调""
      },
      {
        ""eventName"": ""SetMsgReadedReceiptCallback"",
        ""eventText"": ""消息已读回执回调"",
        ""eventDesc"": ""设置消息已读回执回调""
      },
      {
        ""eventName"": ""SetMsgRevokeCallback"",
        ""eventText"": ""接收的消息被撤回回调"",
        ""eventDesc"": ""设置接收的消息被撤回回调""
      },
      {
        ""eventName"": ""SetGroupTipsEventCallback"",
        ""eventText"": ""群组系统消息回调"",
        ""eventDesc"": ""设置群组系统消息回调""
      },
      {
        ""eventName"": ""SetMsgElemUploadProgressCallback"",
        ""eventText"": ""消息内元素相关文件上传进度回调"",
        ""eventDesc"": ""设置消息内元素相关文件上传进度回调""
      }
    ]";
  }
}