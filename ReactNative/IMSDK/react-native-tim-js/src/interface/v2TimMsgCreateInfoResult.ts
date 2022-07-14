/**
 * @module interface
 */
import type { V2TimMessage } from './v2TimMessage';

export interface V2TimMsgCreateInfoResult {
    id?: string;
    messageInfo: V2TimMessage;
}
