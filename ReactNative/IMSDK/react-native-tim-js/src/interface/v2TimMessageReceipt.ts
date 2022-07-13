/**
 * @module interface
 */
interface V2TimMessageReceipt {
    userID: String;
    timestamp: number;
    groupID?: String;
    msgID?: String;
    readCount?: number;
    unreadCount?: number;
}

export default V2TimMessageReceipt;
