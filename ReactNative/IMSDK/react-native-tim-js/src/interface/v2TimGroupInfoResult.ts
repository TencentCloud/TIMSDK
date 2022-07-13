/**
 * @module interface
 */
import type V2TimGroupInfo from './v2TimGroupInfo';

interface V2TimGroupInfoResult {
    resultCode?: number;
    resultMessage?: String;
    groupInfo?: V2TimGroupInfo;
}

export default V2TimGroupInfoResult;
