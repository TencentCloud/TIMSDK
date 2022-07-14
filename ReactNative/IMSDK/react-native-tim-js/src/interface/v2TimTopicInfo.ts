/**
 * @module interface
 */
import type { V2TimGroupAtInfo } from './v2TimGroupAtInfo';
import type { V2TimMessage } from './v2TimMessage';

export interface V2TimTopicInfo {
    topicID?: string;
    topicName?: string;
    topicFaceUrl?: string;
    introduction?: string;
    notification?: string;
    isAllMute?: boolean;
    selfMuteTime?: number;
    customString?: string;
    recvOpt?: number;
    draftText?: string;
    unreadCount?: number;
    lastMessage?: V2TimMessage;
    groupAtInfoList?: V2TimGroupAtInfo[];
}
