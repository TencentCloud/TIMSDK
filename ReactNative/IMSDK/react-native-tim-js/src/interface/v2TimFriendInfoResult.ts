/**
 * @module interface
 */
import type V2TimFriendInfo from './v2TimFriendInfo';

interface V2TimFriendInfoResult {
    resultCode: number;
    resultInfo?: String;
    relation?: number;
    friendInfo?: V2TimFriendInfo;
}

export default V2TimFriendInfoResult;
