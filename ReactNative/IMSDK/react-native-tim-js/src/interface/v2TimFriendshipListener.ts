/**
 * @module interface
 */
import type V2TimFriendApplication from './v2TimFriendApplication';
import type V2TimFriendInfo from './v2TimFriendInfo';

interface V2TimFriendshipListener {
    onFriendApplicationListAdded: (
        applicationList: V2TimFriendApplication
    ) => void;
    onFriendApplicationListDeleted: (userIDList: String[]) => void;
    onFriendApplicationListRead: () => void;
    onFriendListAdded: (users: V2TimFriendInfo[]) => void;
    onFriendListDeleted: (userList: String[]) => void;
    onBlackListAdd: (users: V2TimFriendInfo[]) => void;
    onBlackListDeleted: (userList: String[]) => void;
    onFriendInfoChanged: (users: V2TimFriendInfo[]) => void;
}

export default V2TimFriendshipListener;
