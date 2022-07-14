/**
 * @module interface
 */
import type { V2TimUserInfo } from './v2TimUserInfo';

export interface V2TimSimpleMsgListener {
    onRecvC2CCustomMessage?: (
        msgID: string,
        sender: V2TimUserInfo,
        customData: string
    ) => void;
    onRecvC2CTextMessage?: (
        msgID: string,
        sender: V2TimUserInfo,
        text: string
    ) => void;
    onRecvGroupCustomMessage?: (
        msgID: string,
        groupID: string,
        sender: V2TimUserInfo,
        customData: string
    ) => void;
    onRecvGroupTextMessage?: (
        msgID: string,
        groupID: string,
        sender: V2TimUserInfo,
        text: string
    ) => void;
}
