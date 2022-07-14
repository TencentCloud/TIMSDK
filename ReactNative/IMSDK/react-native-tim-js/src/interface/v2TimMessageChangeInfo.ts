/**
 * @module interface
 */
import type { V2TimMessage } from './v2TimMessage';

export interface V2TimMessageChangeInfo {
    code?: number;
    desc?: string;
    message?: V2TimMessage;
}
