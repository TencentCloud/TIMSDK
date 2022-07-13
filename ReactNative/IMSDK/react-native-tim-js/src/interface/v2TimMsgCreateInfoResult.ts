/**
 * @module interface
 */
import type V2TimMessage from './v2TimMessage';

interface V2TimMsgCreateInfoResult {
    id?: String;
    messageInfo: V2TimMessage;
}

export default V2TimMsgCreateInfoResult;
