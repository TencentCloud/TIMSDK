/**
 * @module interface
 */
import type V2TimOfflinePushInfo from './v2TimOfflinePushInfo';

interface V2TimSignalingInfo {
    inviteID: String; // 邀请ID
    inviter: String; // 邀请人ID
    inviteeList: [];
    groupID?: String;
    data?: String;
    timeout?: number;
    actionType: number;
    businessID?: number; // ios不回返回这条
    isOnlineUserOnly?: boolean; // ios不回返回这条
    offlinePushInfo?: V2TimOfflinePushInfo; // ios不回返回这条
}

export default V2TimSignalingInfo;
