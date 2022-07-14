/**
 * @module interface
 */
import type { V2TimTopicInfo } from './v2TimTopicInfo';

export interface V2TimTopicInfoResult {
    errorCode?: number;
    errorMessage?: string;
    topicInfo?: V2TimTopicInfo;
}
