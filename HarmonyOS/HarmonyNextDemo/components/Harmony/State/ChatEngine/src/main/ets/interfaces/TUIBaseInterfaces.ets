// 定义 TUIBaseMessage 接口
interface TUIBaseMessage {
  messageID: string;
  messageSender: string;
  messageStatus: number;
}

// 定义 TUIBaseConversation 接口
interface TUIBaseConversation {
  conversationID: string;
  conversationType: number;
  title: string;
}

export { TUIBaseMessage, TUIBaseConversation };
