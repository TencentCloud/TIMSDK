/**
 * @module interface
 */
import type V2TimUserInfo from './v2TimUserInfo';

interface V2TimSimpleMsgListener {
    onRecvC2CCustomMessage: (
        msgID: String,
        sender: V2TimUserInfo,
        customData: String
    ) => void;
    onRecvC2CTextMessage: (
        msgID: String,
        sender: V2TimUserInfo,
        text: String
    ) => void;
    onRecvGroupCustomMessage: (
        msgID: String,
        groupID: String,
        sender: V2TimUserInfo,
        customData: String
    ) => void;
    onRecvGroupTextMessage: (
        msgID: String,
        groupID: String,
        sender: V2TimUserInfo,
        text: String
    ) => void;
}

export default V2TimSimpleMsgListener;
