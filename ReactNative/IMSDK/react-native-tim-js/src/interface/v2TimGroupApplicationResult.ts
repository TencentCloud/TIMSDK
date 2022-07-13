/**
 * @module interface
 */
import type V2TimGroupApplication from './v2TimGroupApplication';

interface V2TimGroupApplicationResult {
    unreadCount?: number;
    groupApplicationList?: V2TimGroupApplication[];
}

export default V2TimGroupApplicationResult;
