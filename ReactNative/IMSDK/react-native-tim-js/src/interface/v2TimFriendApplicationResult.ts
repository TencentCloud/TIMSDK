/**
 * @module interface
 */
import type { V2TimFriendApplication } from './v2TimFriendApplication';

export interface V2TimFriendApplicationResult {
    unReadCount?: number;
    friendApplicationList?: V2TimFriendApplication[];
}
