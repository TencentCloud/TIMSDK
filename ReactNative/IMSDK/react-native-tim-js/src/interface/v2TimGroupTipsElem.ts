/**
 * @module interface
 */
import type V2TimGroupChangeInfo from './v2TimGroupChangeInfo';
import type V2TimGroupMemberChangeInfo from './v2TimGroupMemberChangeInfo';
import type V2TimGroupMemberInfo from './v2TimGroupMemberInfo';

interface V2TimGroupTipsElem {
    groupID: String;
    type: number;
    opMember: V2TimGroupMemberInfo;
    memberList?: V2TimGroupMemberInfo[];
    groupChangeInfoList?: V2TimGroupChangeInfo[];
    memberChangeInfoList?: V2TimGroupMemberChangeInfo[];
    memberCount?: number;
}

export default V2TimGroupTipsElem;
