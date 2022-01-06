enum ReceiveMsgOptEnum {
  //在线正常接收消息，离线时会进行离线推送
  V2TIM_RECEIVE_MESSAGE,
  //不会接收到消息
  V2TIM_NOT_RECEIVE_MESSAGE,
  //在线正常接收消息，离线不会有推送通知
  V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE,
}
