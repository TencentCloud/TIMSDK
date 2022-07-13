/**
 * @module interface
 */
import type { GroupMemberRoleTypeEnum } from '../enum/groupMemberRoleType';

interface V2TimGroupMember {
    userID: String;
    role: GroupMemberRoleTypeEnum;
}

export default V2TimGroupMember;
