import 'package:tim_ui_kit/business_logic/life_cycle/base_life_cycle.dart';

class ConversationLifeCycle {
  /// Before deleting a conversation, or a channel, from the conversation list,
  /// `true` means can delete continually, while `false` will not delete.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String conversationID) shouldDeleteConversation;

  /// Before clearing the historical message for a specific conversation, provided in parameter,
  /// `true` means can clear continually, while `false` will not clear.
  /// You can make a second confirmation here by a modal, etc.
  FutureBool Function(String conversationID)
      shouldClearHistoricalMessageForConversation;

  /// Before conversation list will mount or update to conversation page.
  ConversationListFunction conversationListWillMount;

  ConversationLifeCycle({
    this.conversationListWillMount =
        DefaultLifeCycle.defaultConversationListSolution,
    this.shouldClearHistoricalMessageForConversation =
        DefaultLifeCycle.defaultBooleanSolution,
    this.shouldDeleteConversation = DefaultLifeCycle.defaultBooleanSolution,
  });
}
