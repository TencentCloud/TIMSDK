/**
 * @module interface
 */
import type { StringMap } from './commonInterface';
import type { V2TimUserFullInfo } from './v2TimUserFullInfo';

export interface V2TimFriendInfo {
    userID: string;
    friendRemark?: string;
    friendGroups?: string[];
    friendCustomInfo?: StringMap;
    userProfile?: V2TimUserFullInfo;
}
