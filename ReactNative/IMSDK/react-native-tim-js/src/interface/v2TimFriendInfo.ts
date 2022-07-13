/**
 * @module interface
 */
import type { StringMap } from './commonInterface';
import type V2TimUserFullInfo from './v2TimUserFullInfo';

interface V2TimFriendInfo {
    userID: String;
    friendRemark?: String;
    friendGroups?: String[];
    friendCustomInfo?: StringMap;
    userProfile?: V2TimUserFullInfo;
}

export default V2TimFriendInfo;
