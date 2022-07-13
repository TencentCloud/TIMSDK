/**
 * @module interface
 */
import type V2TimGroupMemberInfo from './v2TimGroupMemberInfo';

interface V2TimGroupMessageReadMemberList {
    nextSeq: number;
    isFinished: boolean;
    memberInfoList: V2TimGroupMemberInfo[];
}

export default V2TimGroupMessageReadMemberList;
