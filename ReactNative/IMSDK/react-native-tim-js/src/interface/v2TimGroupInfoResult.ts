/**
 * @module interface
 */
import type { V2TimGroupInfo } from './v2TimGroupInfo';

export interface V2TimGroupInfoResult {
    resultCode?: number;
    resultMessage?: string;
    groupInfo?: V2TimGroupInfo;
}
