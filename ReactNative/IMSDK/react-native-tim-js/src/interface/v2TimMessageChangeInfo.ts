/**
 * @module interface
 */
import type V2TimMessage from './v2TimMessage';

interface V2TimMessageChangeInfo {
    code?: number;
    desc?: String;
    message?: V2TimMessage;
}

export default V2TimMessageChangeInfo;
