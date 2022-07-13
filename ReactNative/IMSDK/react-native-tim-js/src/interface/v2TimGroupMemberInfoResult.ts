/**
 * @module interface
 */
import type V2TimGroupMemberFullInfo from './v2TimGroupMemberFullInfo';

interface V2TimGroupMemberInfoResult {
    nextSeq?: String;
    memberInfoList?: V2TimGroupMemberFullInfo[];
}

export default V2TimGroupMemberInfoResult;
