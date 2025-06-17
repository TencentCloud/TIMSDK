/**
 * 消息列表样式枚举
 */
export enum MessageListStyle {
  Normal = 'normal', // 普通聊天样式
  RoomStyle = 'room' // 直播间样式
}

/**
 * 默认的消息列表样式
 */
export const DEFAULT_MESSAGE_LIST_STYLE: MessageListStyle = MessageListStyle.Normal;