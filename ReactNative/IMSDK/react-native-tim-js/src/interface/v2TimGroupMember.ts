/**
 * @module interface
 */
import type { GroupMemberRoleTypeEnum } from '../enum/groupMemberRoleType';

export interface V2TimGroupMember {
    userID: string;
    role: GroupMemberRoleTypeEnum;
}
