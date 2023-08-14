
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import <TIMCommon/TUITextView.h>
#import "TUIChatDefine.h"
#import "TUITextMessageCellData.h"

@interface TUITextMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist <UITextViewDelegate>

/**
 *  展示文本消息的内容容器
 *  TextView for display text message content
 */
@property(nonatomic, strong) TUITextView *textView;

/**
 *  选中文本内容
 *  Selected text content
 */
@property(nonatomic, strong) NSString *selectContent;

/**
 *  选中全部文本回调
 *  Callback for selected all text
 */
@property(nonatomic, strong) TUIChatSelectAllContentCallback selectAllContentContent;

@property TUITextMessageCellData *textData;

@property(nonatomic, strong) UIImageView *voiceReadPoint;

- (void)fillWithData:(TUITextMessageCellData *)data;

@end


@interface TUITextMessageCell_Minimalist (TUILayoutConfiguration)

/**
 *  文本消息颜色（发送）
 *  在消息方向为发送时使用。
 *
 *  The color of label which displays the text message content.
 *  Used when the message direction is send.
 */
@property(nonatomic, class) UIColor *outgoingTextColor;

/**
 *  文本消息字体（发送）
 *  在消息方向为发送时使用。
 *
 *  The font of label which displays the text message content.
 *  Used when the message direction is send.
 */
@property(nonatomic, class) UIFont *outgoingTextFont;

/**
 *  文本消息颜色（接收）
 *  在消息方向为接收时使用。
 *
 *  The color of label which displays the text message content.
 *  Used when the message direction is received.
 */
@property(nonatomic, class) UIColor *incommingTextColor;

/**
 *  文本消息字体（接收）
 *  在消息方向为接收时使用。
 *
 *  The font of label which displays the text message content.
 *  Used when the message direction is received.
 */
@property(nonatomic, class) UIFont *incommingTextFont;


@end
