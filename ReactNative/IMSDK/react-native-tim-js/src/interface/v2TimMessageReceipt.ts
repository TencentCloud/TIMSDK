/**
 * @module interface
 */
export interface V2TimMessageReceipt {
    userID: string;
    timestamp: number;
    groupID?: string;
    msgID?: string;
    readCount?: number;
    unreadCount?: number;
}
