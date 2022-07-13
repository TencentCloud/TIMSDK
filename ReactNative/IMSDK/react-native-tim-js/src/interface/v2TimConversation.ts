/**
 * @module interface
 */
import type V2TimGroupAtInfo from './v2TimGroupAtInfo';
import type V2TimMessage from './v2TimMessage';

interface V2TimConversation {
    conversationID: String;
    type?: number;
    userID?: String;
    groupID?: String;
    showName?: String;
    faceUrl?: String;
    groupType?: String;
    unreadCount?: number;
    lastMessage?: V2TimMessage;
    draftText?: String;
    draftTimestamp?: number;
    isPinned?: boolean;
    recvOpt?: number;
    groupAtInfoList?: V2TimGroupAtInfo[];
    orderkey?: number;
}

export default V2TimConversation;
