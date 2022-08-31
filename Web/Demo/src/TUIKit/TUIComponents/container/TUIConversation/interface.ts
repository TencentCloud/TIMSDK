export interface Conversation {
  conversationID?: string;
  type?: string;
  subType?: string;
  unreadCount?: number;
  lastMessage?: {
    nick?: string;
    nameCard?: string;
    lastTime?: number;
    lastSequence?: number;
    fromAccount?: string;
    isPeerRead?: boolean;
    messageForShow?: string;
    type?: string;
    payload?: {
      [propName: string]: any;
    };
  };
  groupProfile?: {
    [propName: string]: any;
  };
  userProfile?: {
    [propName: string]: any;
  };
  groupAtInfoList?: Array<{ [propName: string]: any }>;
  remark?: string;
  isPinned?: boolean;
  messageRemindType?: string;
}
