/**
 * @module interface
 */
import type V2TimGroupAtInfo from './v2TimGroupAtInfo';
import type V2TimMessage from './v2TimMessage';

interface V2TimTopicInfo {
    topicID?: String;
    topicName?: String;
    topicFaceUrl?: String;
    introduction?: String;
    notification?: String;
    isAllMute?: boolean;
    selfMuteTime?: number;
    customString?: String;
    recvOpt?: number;
    draftText?: String;
    unreadCount?: number;
    lastMessage?: V2TimMessage;
    groupAtInfoList?: V2TimGroupAtInfo[];
}

export default V2TimTopicInfo;
