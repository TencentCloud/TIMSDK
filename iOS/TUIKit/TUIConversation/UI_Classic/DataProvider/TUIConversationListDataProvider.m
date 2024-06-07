//
//  V2TUIConversationListDataProvider.m
//  TUIConversation
//
//  Created by harvy on 2022/7/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationListDataProvider.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import "TUIConversationCellData.h"

@implementation TUIConversationListDataProvider
- (Class)getConversationCellClass {
    return [TUIConversationCellData class];
}

- (void)asnycGetLastMessageDisplay:(NSArray<TUIConversationCellData *> *)duplicateDataList addedDataList:(NSArray<TUIConversationCellData *> *)addedDataList {
    NSMutableArray *allConversationList = [NSMutableArray array];
    [allConversationList addObjectsFromArray:duplicateDataList];
    [allConversationList addObjectsFromArray:addedDataList];

    NSMutableArray *messageList = [NSMutableArray array];
    for (TUIConversationCellData *cellData in allConversationList) {
        if (cellData.lastMessage && cellData.lastMessage.msgID) {
            [messageList addObject:cellData.lastMessage];
        }
    }

    if (messageList.count == 0) {
        return;
    }

    __weak typeof(self) weakSelf = self;
    NSDictionary *param = @{TUICore_TUIChatService_AsyncGetDisplayStringMethod_MsgListKey : messageList};
    [TUICore callService:TUICore_TUIChatService
                  method:TUICore_TUIChatService_AsyncGetDisplayStringMethod
                   param:param
          resultCallback:^(NSInteger errorCode, NSString *_Nonnull errorMessage, NSDictionary *_Nonnull param) {
            if (0 != errorCode) {
                return;
            }

            // cache
            NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithDictionary:weakSelf.lastMessageDisplayMap];
            [param enumerateKeysAndObjectsUsingBlock:^(NSString *msgID, NSString *displayString, BOOL *_Nonnull stop) {
              [dictM setObject:displayString forKey:msgID];
            }];
            weakSelf.lastMessageDisplayMap = [NSDictionary dictionaryWithDictionary:dictM];

            // Refresh if needed
            NSMutableArray *needRefreshConvList = [NSMutableArray array];
            for (TUIConversationCellData *cellData in allConversationList) {
                if (cellData.lastMessage && cellData.lastMessage.msgID && [param.allKeys containsObject:cellData.lastMessage.msgID]) {
                    cellData.subTitle = [self getLastDisplayString:cellData.innerConversation];
                    cellData.foldSubTitle = [self getLastDisplayStringForFoldList:cellData.innerConversation];
                    [needRefreshConvList addObject:cellData];
                }
            }
            NSMutableDictionary<NSString *, NSNumber *> *conversationMap = [NSMutableDictionary dictionary];
            for (TUIConversationCellData *item in weakSelf.conversationList) {
                if (item.conversationID) {
                    [conversationMap setObject:@([weakSelf.conversationList indexOfObject:item]) forKey:item.conversationID];
                }
            }
            [weakSelf handleUpdateConversationList:needRefreshConvList positions:conversationMap];
          }];
}

- (NSString *)getDisplayStringFromService:(V2TIMMessage *)msg {
    // from cache
    NSString *displayString = [self.lastMessageDisplayMap objectForKey:msg.msgID];
    if (displayString.length > 0) {
        return displayString;
    }

    // from TUIChat
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
    BOOL hasRiskContent = conv.lastMessage.hasRiskContent;
    BOOL isRevoked = (conv.lastMessage.status == V2TIM_MSG_STATUS_LOCAL_REVOKED);

    /**
     * If there is a draft box, the draft box information will be displayed first
     */
    if (conv.draftText.length > 0) {
        NSAttributedString *draft = [[NSAttributedString alloc] initWithString:TIMCommonLocalizableString(TUIKitMessageTypeDraftFormat)
                                                                    attributes:@{NSForegroundColorAttributeName : RGB(250, 81, 81)}];
        [attributeString appendAttributedString:draft];

        NSString *draftContentStr = [self getDraftContent:conv];
        draftContentStr = [draftContentStr getLocalizableStringWithFaceContent];
        NSAttributedString *draftContent = [[NSAttributedString alloc] initWithString:draftContentStr
                                                                           attributes:@{NSForegroundColorAttributeName : [UIColor d_systemGrayColor]}];

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
            lastMsgStr = [self getDisplayStringFromService:conv.lastMessage];
        }

        /**
         * If there is no lastMsg display information and no draft information, return nil directly
         */
        if (lastMsgStr.length == 0) {
            return nil;
        }

        if (hasRiskContent && !isRevoked) {
            [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:lastMsgStr
                                                                                    attributes:@{NSForegroundColorAttributeName : RGB(233, 68, 68)}]];
        } else {
            [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:lastMsgStr]];
        }
    }

    /**
     * Meeting  V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE ，UI
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
    if (!conv.draftText && (V2TIM_MSG_STATUS_SENDING == conv.lastMessage.status || V2TIM_MSG_STATUS_SEND_FAIL == conv.lastMessage.status || hasRiskContent) &&
        !isRevoked) {
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
