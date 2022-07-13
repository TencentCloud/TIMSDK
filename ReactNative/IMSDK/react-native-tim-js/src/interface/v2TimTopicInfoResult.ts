/**
 * @module interface
 */
import type V2TimTopicInfo from './v2TimTopicInfo';

interface V2TimTopicInfoResult {
    errorCode?: number;
    errorMessage?: String;
    topicInfo?: V2TimTopicInfo;
}

export default V2TimTopicInfoResult;
