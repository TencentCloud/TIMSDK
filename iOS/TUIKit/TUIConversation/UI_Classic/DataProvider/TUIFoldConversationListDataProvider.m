//
//  TUIFoldConversationListDataProvider.m
//  TUIConversation
//
//  Created by wyl on 2022/11/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFoldConversationListDataProvider.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import "TUIConversationCellData.h"
#import <TIMCommon/NSString+TUIEmoji.h>

@implementation TUIFoldConversationListDataProvider

- (Class)getConversationCellClass {
    return [TUIConversationCellData class];
}

- (NSString *)getDisplayStringFromService:(V2TIMMessage *)msg {
    NSDictionary *param = @{TUICore_TUIChatService_GetDisplayStringMethod_MsgKey : msg};
    return [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_GetDisplayStringMethod param:param];
}

- (NSMutableAttributedString *)getLastDisplayString:(V2TIMConversation *)conv {
    /**
     * If has group-at message, the group-at information will be displayed first
     */
    NSString *atStr = [self getGroupAtTipString:conv];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:atStr];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName : [UIColor d_systemRedColor]};
    [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];

    /**
     * If there is a draft box, the draft box information will be displayed first
     */
    if (conv.draftText.length > 0) {
        NSAttributedString *draft = [[NSAttributedString alloc] initWithString:TIMCommonLocalizableString(TUIKitMessageTypeDraftFormat)
                                                                    attributes:@{NSForegroundColorAttributeName : RGB(250, 81, 81)}];
        [attributeString appendAttributedString:draft];

        NSString *draftContentStr = [self getDraftContent:conv];
        
        NSMutableAttributedString *draftContent = [draftContentStr getAdvancedFormatEmojiStringWithFont:[UIFont systemFontOfSize:16.0]
                                                                                         textColor:TUIChatDynamicColor(@"chat_input_text_color", @"#000000")
                                                                                    emojiLocations:nil];
        [attributeString appendAttributedString:draftContent];
    } else {
        /**
         * No drafts, show conversation lastMsg information
         */
        NSString *lastMsgStr = @"";

        /**
         * Attempt to get externally customized display information
         */
        if (self.delegate && [self.delegate respondsToSelector:@selector(getConversationDisplayString:)]) {
            lastMsgStr = [self.delegate getConversationDisplayString:conv];
        }

        /**
         * If there is no external customization, get the lastMsg display information through the message module
         */
        if (lastMsgStr.length == 0 && conv.lastMessage) {
            NSDictionary *param = @{TUICore_TUIChatService_GetDisplayStringMethod_MsgKey : conv.lastMessage};
            lastMsgStr = [TUICore callService:TUICore_TUIChatService method:TUICore_TUIChatService_GetDisplayStringMethod param:param];
        }

        /**
         * If there is no lastMsg display information and no draft information, return nil directly
         */
        if (lastMsgStr.length == 0) {
            return nil;
        }
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:lastMsgStr]];
    }

    /**
     *
     * If do-not-disturb is set, the message do-not-disturb state is displayed
     * The default state of the meeting type group is V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE, and the UI does not process it.
     */
    if ([self isConversationNotDisturb:conv] && conv.unreadCount > 0) {
        NSAttributedString *unreadString = [[NSAttributedString alloc]
            initWithString:[NSString stringWithFormat:@"[%d %@] ", conv.unreadCount, TIMCommonLocalizableString(TUIKitMessageTypeLastMsgCountFormat)]];
        [attributeString insertAttributedString:unreadString atIndex:0];
    }

    /**
     * If the status of the lastMsg of the conversation is sending or failed, display the sending status of the message (the draft box does not need to display
     * the sending status)
     */
    if (!conv.draftText && (V2TIM_MSG_STATUS_SENDING == conv.lastMessage.status || V2TIM_MSG_STATUS_SEND_FAIL == conv.lastMessage.status)) {
        UIFont *textFont = [UIFont systemFontOfSize:14];
        NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName : textFont}];
        NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
        UIImage *image = nil;
        if (V2TIM_MSG_STATUS_SENDING == conv.lastMessage.status) {
            image = TUIConversationCommonBundleImage(@"msg_sending_for_conv");
        } else {
            image = TUIConversationCommonBundleImage(@"msg_error_for_conv");
        }
        attchment.image = image;
        attchment.bounds = CGRectMake(0, -(textFont.lineHeight - textFont.pointSize) / 2, textFont.pointSize, textFont.pointSize);
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
        [attributeString insertAttributedString:spaceString atIndex:0];
        [attributeString insertAttributedString:imageString atIndex:0];
    }
    return attributeString;
}

@end
