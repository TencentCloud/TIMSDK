/**
 * @module interface
 */
import type { V2TimGroupApplication } from './v2TimGroupApplication';

export interface V2TimGroupApplicationResult {
    unreadCount?: number;
    groupApplicationList?: V2TimGroupApplication[];
}
