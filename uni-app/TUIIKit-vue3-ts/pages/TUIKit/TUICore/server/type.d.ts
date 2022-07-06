export type TUICoreParams = {
  SDKAppID: number;
  tim?: any;
}

export type TUICoreLoginParams = {
  userID: string;
  userSig: string;
}

export type TUIServer = {
  [propName: string]: any;
}

export type TUIStoreType =  {
  [propName: string]: any;
}

// pages

export type groupType = {
  groupID: string;
  [propName: string]: any;
}
export type userProfileType = {
  userID: string;
  [propName: string]: any;
}
export type conversationType = {
  conversationID: string;
  type?: string;
  subType?: string;
  unreadCount?: number;
  lastMessage?: object;
  groupProfile?: groupType;
  userProfile?: userProfileType;
  groupAtInfoList?: Array<any>;
  remark?:	string;
  isPinned?: boolean;
}

export type TUIChatStoreType = {
  conversation: conversationType;
  messageList: Array<any>;
}

export type TUIConversationStoreType = {
  conversation: conversationType;
  conversationList: Array<any>;
}

