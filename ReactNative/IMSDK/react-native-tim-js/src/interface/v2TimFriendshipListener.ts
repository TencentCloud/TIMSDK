/**
 * @module interface
 */
import type { V2TimFriendApplication } from './v2TimFriendApplication';
import type { V2TimFriendInfo } from './v2TimFriendInfo';

export interface V2TimFriendshipListener {
    onFriendApplicationListAdded?: (
        applicationList: V2TimFriendApplication
    ) => void;
    onFriendApplicationListDeleted?: (userIDList: string[]) => void;
    onFriendApplicationListRead?: () => void;
    onFriendListAdded?: (users: V2TimFriendInfo[]) => void;
    onFriendListDeleted?: (userList: string[]) => void;
    onBlackListAdd?: (users: V2TimFriendInfo[]) => void;
    onBlackListDeleted?: (userList: string[]) => void;
    onFriendInfoChanged?: (users: V2TimFriendInfo[]) => void;
}
