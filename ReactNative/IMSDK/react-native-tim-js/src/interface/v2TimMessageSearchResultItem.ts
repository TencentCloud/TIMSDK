/**
 * @module interface
 */
import type { V2TimMessage } from './v2TimMessage';

export interface V2TimMessageSearchResultItem {
    conversationID?: string;
    messageCount?: number;
    messageList?: V2TimMessage[];
}
