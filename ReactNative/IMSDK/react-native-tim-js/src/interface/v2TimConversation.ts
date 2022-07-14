/**
 * @module interface
 */
import type { V2TimGroupAtInfo } from './v2TimGroupAtInfo';
import type { V2TimMessage } from './v2TimMessage';

export interface V2TimConversation {
    conversationID: string;
    type?: number;
    userID?: string;
    groupID?: string;
    showName?: string;
    faceUrl?: string;
    groupType?: string;
    unreadCount?: number;
    lastMessage?: V2TimMessage;
    draftText?: string;
    draftTimestamp?: number;
    isPinned?: boolean;
    recvOpt?: number;
    groupAtInfoList?: V2TimGroupAtInfo[];
    orderkey?: number;
}
