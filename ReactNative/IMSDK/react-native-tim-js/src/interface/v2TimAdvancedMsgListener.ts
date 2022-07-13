/**
 * @module interface
 */
import type V2TimMessage from './v2TimMessage';
import type V2TimMessageReceipt from './v2TimMessageReceipt';

interface V2TimAdvancedMsgListener {
    onRecvNewMessage: (message: V2TimMessage) => void;
    onRecvMessageModified: (message: V2TimMessage) => void;
    onSendMessageProgress: (message: V2TimMessage, progress: number) => void;
    onRecvC2CReadReceipt: (receiptList: V2TimMessageReceipt[]) => void;
    onRecvMessageRevoked: (msgID: String) => void;
    onRecvMessageReadReceipts: (receiptList: V2TimMessageReceipt[]) => void;
}

export default V2TimAdvancedMsgListener;
