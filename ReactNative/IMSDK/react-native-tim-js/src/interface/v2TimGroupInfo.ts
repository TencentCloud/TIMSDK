/**
 * @module interface
 */
import type { StringMap } from './commonInterface';

interface V2TimGroupInfo {
    groupID: String;
    groupType: String;
    groupName?: String;
    notification?: String;
    introduction?: String;
    faceUrl?: String;
    isAllMuted?: Boolean;
    isSupportTopic?: Boolean;
    owner?: String;
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

export default V2TimGroupInfo;
