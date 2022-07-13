/**
 * @module interface
 */
import type { StringMap } from './commonInterface';
import type V2TimGroupChangeInfo from './v2TimGroupChangeInfo';
import type V2TimGroupMemberChangeInfo from './v2TimGroupMemberChangeInfo';
import type V2TimGroupMemberInfo from './v2TimGroupMemberInfo';

interface V2TimGroupListener {
    onMemberEnter: (
        groupID: String,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onMemberLeave: (groupID: String, member: V2TimGroupMemberInfo) => void;
    onMemberInvited: (
        groupID: String,
        opUser: V2TimGroupMemberInfo,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onMemberKicked: (
        groupID: String,
        opUser: V2TimGroupMemberInfo,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onMemberInfoChanged: (
        groupID: String,
        groupMemberChangeInfoList: V2TimGroupMemberChangeInfo[]
    ) => void;
    onGroupCreated: (groupID: String) => void;
    onGroupDismissed: (groupID: String, opUser: V2TimGroupMemberInfo) => void;
    onGroupRecycled: (groupID: String, opUser: V2TimGroupMemberInfo) => void;
    onGroupInfoChanged: (
        groupID: String,
        changeInfos: V2TimGroupChangeInfo[]
    ) => void;
    onReceiveJoinApplication: (
        groupID: String,
        member: V2TimGroupMemberInfo,
        opReason: String
    ) => void;
    onApplicationProcessed: (
        groupID: String,
        opUser: V2TimGroupMemberInfo,
        isAgreeJoin: Boolean,
        opReason: String
    ) => void;
    onGrantAdministrator: (
        groupID: String,
        opUser: V2TimGroupMemberInfo,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onRevokeAdministrator: (
        groupID: String,
        opUser: V2TimGroupMemberInfo,
        memberList: V2TimGroupMemberInfo[]
    ) => void;
    onQuitFromGroup: (groupID: String) => void;
    onReceiveRESTCustomData: (groupID: String, customData: String) => void;
    onGroupAttributeChanged: (
        groupID: String,
        groupAttribute: StringMap
    ) => void;
}

export default V2TimGroupListener;
