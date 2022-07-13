/**
 * @module interface
 */
import type { StringMap } from './commonInterface';

interface V2TimGroupMemberFullInfo {
    userID?: String;
    nickName?: String;
    nameCard?: String;
    friendRemark?: String;
    faceUrl?: String;
    role?: number;
    muteUntil?: number;
    joinTime?: number;
    customInfo?: StringMap;
}

export default V2TimGroupMemberFullInfo;
