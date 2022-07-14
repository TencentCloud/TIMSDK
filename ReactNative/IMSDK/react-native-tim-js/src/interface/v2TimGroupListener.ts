/**
 * @module interface
 */
import type { StringMap } from './commonInterface';
import type { V2TimGroupChangeInfo } from './v2TimGroupChangeInfo';
import type { V2TimGroupMemberChangeInfo } from './v2TimGroupMemberChangeInfo';
import type { V2TimGroupMemberInfo } from './v2TimGroupMemberInfo';

export interface V2TimGroupListener {
    onMemberEnter?: (
        groupID: string,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onMemberLeave?: (groupID: string, member: V2TimGroupMemberInfo) => void;
    onMemberInvited?: (
        groupID: string,
        opUser: V2TimGroupMemberInfo,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onMemberKicked?: (
        groupID: string,
        opUser: V2TimGroupMemberInfo,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onMemberInfoChanged?: (
        groupID: string,
        groupMemberChangeInfoList: V2TimGroupMemberChangeInfo[]
    ) => void;
    onGroupCreated?: (groupID: string) => void;
    onGroupDismissed?: (groupID: string, opUser: V2TimGroupMemberInfo) => void;
    onGroupRecycled?: (groupID: string, opUser: V2TimGroupMemberInfo) => void;
    onGroupInfoChanged?: (
        groupID: string,
        changeInfos: V2TimGroupChangeInfo[]
    ) => void;
    onReceiveJoinApplication?: (
        groupID: string,
        member: V2TimGroupMemberInfo,
        opReason: string
    ) => void;
    onApplicationProcessed?: (
        groupID: string,
        opUser: V2TimGroupMemberInfo,
        isAgreeJoin: Boolean,
        opReason: string
    ) => void;
    onGrantAdministrator?: (
        groupID: string,
        opUser: V2TimGroupMemberInfo,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onRevokeAdministrator?: (
        groupID: string,
        opUser: V2TimGroupMemberInfo,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onQuitFromGroup?: (groupID: string) => void;
    onReceiveRESTCustomData?: (groupID: string, customData: string) => void;
    onGroupAttributeChanged?: (
        groupID: string,
        groupAttribute: StringMap
    ) => void;
}
