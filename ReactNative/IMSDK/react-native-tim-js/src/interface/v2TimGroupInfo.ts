/**
 * @module interface
 */
import type { StringMap } from './commonInterface';

export interface V2TimGroupInfo {
    groupID: string;
    groupType: string;
    groupName?: string;
    notification?: string;
    introduction?: string;
    faceUrl?: string;
    isAllMuted?: Boolean;
    isSupportTopic?: Boolean;
    owner?: string;
    createTime?: number;
    groupAddOpt?: number;
    lastInfoTime?: number;
    lastMessageTime?: number;
    memberCount?: number;
    onlineCount?: number;
    role?: number;
    recvOpt?: number;
    joinTime?: number;
    customInfo?: StringMap;
}
