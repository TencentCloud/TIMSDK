import { ActionSheet, ActionItem, AppBuilderConfig, ConversationAction } from '../../basecomponent/Index';
import { ConversationInfo } from 'chatengine';

export enum ConversationDialogAction {
  HIDE = 'hideConversation',
  PIN = 'pinConversation',
  CLEAR = 'clearConversation',
  DELETE = 'deleteConversation',
  MUTE = 'muteConversation'
}

@CustomDialog
export struct ConversationMoreDialog {
  @ObjectLink conversation: ConversationInfo;
  controller?: CustomDialogController;
  @State actionItems: ActionItem[] = [];
  onAction?: (action: ConversationDialogAction, conversationId: string) => void;

  aboutToAppear() {
    // Generate action items based on AppBuilderConfig.conversationActionList
    const config = AppBuilderConfig.getInstance();
    const configuredActions: ActionItem[] = [];

    if (config.conversationActionList && config.conversationActionList.length > 0) {
      for (const conversationAction of config.conversationActionList) {
        // Skip MARK_UNREAD as it's handled in the swipe action buttons
        if (conversationAction !== ConversationAction.MARK_UNREAD) {
          const actionItem = this.getActionItem(conversationAction);
          if (actionItem) {
            configuredActions.push(actionItem);
          }
        }
      }
    }

    // Always add clear messages action if not already configured
    const hasDelete = config.conversationActionList.includes(ConversationAction.DELETE);
    if (hasDelete && !configuredActions.some(item => item.value === ConversationDialogAction.CLEAR)) {
      configuredActions.push({
        text: $r('app.string.clear_messages'),
        value: ConversationDialogAction.CLEAR
      });
    }

    this.actionItems = configuredActions;
  }

  build() {
    ActionSheet({
      controller: this.controller!,
      options: this.actionItems,
      showCancel: true,
      cancelText: $r('app.string.cancel'),
      onActionSelected: (item: ActionItem) => {
        this.handleAction(item.value as ConversationDialogAction);
      },
      onDismiss: () => {
        // Handle dialog dismiss
      }
    })
  }

  /**
   * Map ConversationAction to ConversationDialogAction and ActionItem
   */
  private getActionItem(action: ConversationAction): ActionItem | null {
    switch (action) {
      case ConversationAction.DELETE:
        return {
          text: $r('app.string.delete_conversation'),
          value: ConversationDialogAction.DELETE,
          isDestructive: true
        };

      case ConversationAction.PIN:
        return {
          text: this.conversation?.isPinned ?
          $r('app.string.unpin_conversation') :
          $r('app.string.pin_conversation'),
          value: ConversationDialogAction.PIN
        };

    // case ConversationAction.HIDE:
    //   return {
    //     text: $r('app.string.hide_conversation'),
    //     value: ConversationDialogAction.HIDE
    //   };

    // case ConversationAction.MUTE:
    //   return {
    //     text: "set mute",
    //     value: ConversationDialogAction.MUTE
    //   };
      case ConversationAction.CLEAR_HISTORY:
        return {
          text: $r('app.string.clear_messages'),
          value: ConversationDialogAction.CLEAR
        }
    // MARK_UNREAD is handled separately in ActionButtonsBuilder, not in more dialog
      case ConversationAction.MARK_UNREAD:
        return null;

      default:
        return null;
    }
  }

  private handleAction(action: ConversationDialogAction) {
    console.log('ConversationMoreDialog action:', action);

    if (this.onAction) {
      this.onAction(action, this.conversation.ID);
    }
  }
} 