
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This document declares the TUIBubbleMessageCell_Minimalist class.
 *  Bubble messages, the most common type of messages that contain strings and emoticons.
 *  Both TUIFileMessageCell_Minimalist and TUIVoiceMessageCell_Minimalist inherit from this class and implement the userinterface of bubble messages.
 *  If developers want to customize the bubble message, they can also refer to the implementation methods of the above two message units to implement their own
 * bubble message unit.
 */
#import "TUIMessageCell.h"
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIMessageStatus) {
    TUIMessageStatus_Unkown,
    TUIMessageStatus_Sending,
    TUIMessageStatus_Send_Succ,
    TUIMessageStatus_Some_People_Read,
    TUIMessageStatus_All_People_Read,
};

@interface TUIMessageCell_Minimalist : TUIMessageCell
@property(nonatomic, strong) UIImageView *replyLineView;
@property(nonatomic, strong) NSMutableArray *replyAvatarImageViews;
@property(nonatomic, strong) UIImageView *msgStatusView;
@property(nonatomic, strong) UILabel *msgTimeLabel;

- (void)fillWithData:(TUIMessageCellData *)data;
@end

NS_ASSUME_NONNULL_END
