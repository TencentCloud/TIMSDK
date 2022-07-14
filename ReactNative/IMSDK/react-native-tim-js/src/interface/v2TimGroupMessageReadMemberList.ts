/**
 * @module interface
 */
import type { V2TimGroupMemberInfo } from './v2TimGroupMemberInfo';

export interface V2TimGroupMessageReadMemberList {
    nextSeq: number;
    isFinished: boolean;
    memberInfoList: V2TimGroupMemberInfo[];
}
