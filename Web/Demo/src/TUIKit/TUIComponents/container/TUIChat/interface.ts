interface Message {
  ID?: string;
  type?: string;
  payload?: {
    [propName: string]: any;
  };
  conversationID?: string;
  conversationType?: string;
  to?: string;
  from?: string;
  flow?: string;
  time?: number;
  status?: string;
  isRevoked?: boolean;
  priority?: string;
  nick?: string;
  avatar?: string;
  isPeerRead?: boolean;
  nameCard?: string;
  atUserList?: Array<string>;
  cloudCustomData?: string;
  isDeleted?: boolean;
  isModified?: boolean;
  needReadReceipt?: boolean;
  readReceiptInfo?: {
    [propName: string]: any;
  };
  isBroadcastMessage?: boolean;
}

interface userListItem {
  nick?: string;
  avatar: string;
  userID: string;
}

export { Message, userListItem };
