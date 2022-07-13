/**
 * @module interface
 */
import type V2TimMessage from './v2TimMessage';

interface V2TimMessageSearchResultItem {
    conversationID?: String;
    messageCount?: number;
    messageList?: V2TimMessage[];
}

export default V2TimMessageSearchResultItem;
