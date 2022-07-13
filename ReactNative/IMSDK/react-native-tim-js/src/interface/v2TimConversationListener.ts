/**
 * @module interface
 */
import type V2TimConversation from './v2TimConversation';

interface V2TimConversationListener {
    onSyncServerStart?: () => void;
    onSyncServerFinish?: () => void;
    onSyncServerFailed?: () => void;
    onNewConversation?: (conversationList: V2TimConversation[]) => void;
    onTotalUnreadMessageCountChanged?: (totalUnreadCount: number) => void;
    onConversationChanged?: (conversationList: V2TimConversation[]) => void;
}

export default V2TimConversationListener;
