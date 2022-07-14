/**
 * @module interface
 */
import type { StringMap } from './commonInterface';

export interface V2TimGroupMemberFullInfo {
    userID?: string;
    nickName?: string;
    nameCard?: string;
    friendRemark?: string;
    faceUrl?: string;
    role?: number;
    muteUntil?: number;
    joinTime?: number;
    customInfo?: StringMap;
}
