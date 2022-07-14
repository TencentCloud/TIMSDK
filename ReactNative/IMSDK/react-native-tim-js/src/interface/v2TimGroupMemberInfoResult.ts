/**
 * @module interface
 */
import type { V2TimGroupMemberFullInfo } from './v2TimGroupMemberFullInfo';

export interface V2TimGroupMemberInfoResult {
    nextSeq?: string;
    memberInfoList?: V2TimGroupMemberFullInfo[];
}
