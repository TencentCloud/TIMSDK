/**
 * @module interface
 */
import type { V2TimFriendInfo } from './v2TimFriendInfo';

export interface V2TimFriendInfoResult {
    resultCode: number;
    resultInfo?: string;
    relation?: number;
    friendInfo?: V2TimFriendInfo;
}
