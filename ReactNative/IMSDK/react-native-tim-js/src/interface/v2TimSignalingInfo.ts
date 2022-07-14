/**
 * @module interface
 */
import type { V2TimOfflinePushInfo } from './v2TimOfflinePushInfo';

export interface V2TimSignalingInfo {
    inviteID: string; // 邀请ID
    inviter: string; // 邀请人ID
    inviteeList: [];
    groupID?: string;
    data?: string;
    timeout?: number;
    actionType: number;
    businessID?: number; // ios不回返回这条
    isOnlineUserOnly?: boolean; // ios不回返回这条
    offlinePushInfo?: V2TimOfflinePushInfo; // ios不回返回这条
}
