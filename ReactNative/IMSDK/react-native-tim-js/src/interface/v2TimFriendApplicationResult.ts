/**
 * @module interface
 */
import type V2TimFriendApplication from './v2TimFriendApplication';

interface V2TimFriendApplicationResult {
    unReadCount?: number;
    friendApplicationList?: V2TimFriendApplication[];
}

export default V2TimFriendApplicationResult;
