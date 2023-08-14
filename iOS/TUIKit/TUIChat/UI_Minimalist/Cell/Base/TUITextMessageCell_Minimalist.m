//
//  TUITextMessageCell_Minimalist.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextMessageCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIGlobalization.h>

@implementation TUITextMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [[TUITextView alloc] init];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.textView.textContainer.lineFragmentPadding = 0;
        self.textView.scrollEnabled = NO;
        self.textView.editable = NO;
        self.textView.delegate = self;
        [self.bubbleView addSubview:self.textView];

        self.bottomContainer = [[UIView alloc] init];
        [self.contentView addSubview:self.bottomContainer];

        self.voiceReadPoint = [[UIImageView alloc] init];
        self.voiceReadPoint.backgroundColor = [UIColor redColor];
        self.voiceReadPoint.frame = CGRectMake(0, 0, 5, 5);
        self.voiceReadPoint.hidden = YES;
        [self.voiceReadPoint.layer setCornerRadius:self.voiceReadPoint.frame.size.width / 2];
        [self.voiceReadPoint.layer setMasksToBounds:YES];
        [self.bubbleView addSubview:self.voiceReadPoint];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    for (UIView *view in self.bottomContainer.subviews) {
        [view removeFromSuperview];
    }
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData : self.textData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_MinimalistExtensionID parentView:self.bottomContainer param:param];
}

- (void)fillWithData:(TUITextMessageCellData *)data;
{
    // set data
    [super fillWithData:data];
    self.textData = data;
    self.selectContent = data.content;
    self.voiceReadPoint.hidden = !data.showUnreadPoint;
    self.bottomContainer.hidden = CGSizeEqualToSize(data.bottomContainerSize, CGSizeZero);
    
    UIColor *textColor = self.class.incommingTextColor;
    UIFont *textFont = self.class.incommingTextFont;
    if (data.direction == MsgDirectionIncoming) {
        textColor = self.class.incommingTextColor;
        textFont = self.class.incommingTextFont;
    } else {
        textColor = self.class.outgoingTextColor;
        textFont = self.class.outgoingTextFont;
    }
    self.textView.attributedText = [data getAttributedString:textFont];
    self.textView.textColor = textColor;
    self.textView.font = textFont;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textView.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
    if (self.voiceReadPoint.hidden == NO) {
        self.voiceReadPoint.frame = CGRectMake(CGRectGetMaxX(self.bubbleView.frame), 0, 5, 5);
    }

    [self layoutBottomContainer];
}

- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.textData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.textData.bottomContainerSize;
    /// TransitionView should not cover the replyView.
    /// Add an extra tiny offset to the left or right of TransitionView if replyView is visible.
    CGFloat offset = self.replyLineView.hidden ? 0 : 1;
    UIView *view = self.replyEmojiView.hidden ? self.bubbleView : self.replyEmojiView;
    CGFloat topMargin = view.mm_maxY + self.nameLabel.mm_h + 6;

    if (self.textData.direction == MsgDirectionOutgoing) {
        self.bottomContainer.mm_top(topMargin).mm_width(size.width).mm_height(size.height).mm_right(self.mm_w - self.container.mm_maxX + offset);
    } else {
        self.bottomContainer.mm_top(topMargin).mm_width(size.width).mm_height(size.height).mm_left(self.container.mm_minX + offset);
    }

    if (!self.messageModifyRepliesButton.hidden) {
        CGRect oldRect = self.messageModifyRepliesButton.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame) + 5, oldRect.size.width, oldRect.size.height);
        self.messageModifyRepliesButton.frame = newRect;
    }
    for (UIView *view in self.replyAvatarImageViews) {
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, CGRectGetMaxY(self.bottomContainer.frame) + 5, oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
    if (!self.replyLineView.hidden) {
        CGRect oldRect = self.retryView.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y, oldRect.size.width, oldRect.size.height + self.bottomContainer.mm_h);
        self.retryView.frame = newRect;
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSAttributedString *selectedString = [textView.attributedText attributedSubstringFromRange:textView.selectedRange];
    if (self.selectAllContentContent && selectedString.length > 0) {
        if (selectedString.length == textView.attributedText.length) {
            self.selectAllContentContent(YES);
        } else {
            self.selectAllContentContent(NO);
        }
    }
    if (selectedString.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:selectedString];
        NSUInteger offsetLocation = 0;
        for (NSDictionary *emojiLocation in self.textData.emojiLocations) {
            NSValue *key = emojiLocation.allKeys.firstObject;
            NSAttributedString *originStr = emojiLocation[key];
            NSRange currentRange = [key rangeValue];
            /**
             * 每次 emoji 替换后，字符串的长度都会发生变化，后面 emoji 的实际 location 也要相应改变
             * After each emoji is replaced, the length of the string will change, and the actual location of the emoji will also change accordingly.
             */
            currentRange.location += offsetLocation;
            if (currentRange.location >= textView.selectedRange.location) {
                currentRange.location -= textView.selectedRange.location;
                if (currentRange.location + currentRange.length <= attributedString.length) {
                    [attributedString replaceCharactersInRange:currentRange withAttributedString:originStr];
                    offsetLocation += originStr.length - currentRange.length;
                }
            }
        }
        self.selectContent = attributedString.string;
    } else {
        self.selectContent = nil;
    }
}

#pragma mark - TUIMessageCelllProtocol
+ (CGFloat)getEstimatedHeight:(TUIMessageCellData *)data {
    return 44.f;
}

+ (CGFloat)getHeight:(TUIMessageCellData *)data withWidth:(CGFloat)width {
    NSAssert([data isKindOfClass:TUITextMessageCellData.class], @"data must be kind of TUITextMessageCellData");
    TUITextMessageCellData *textCellData = (TUITextMessageCellData *)data;
    
    CGFloat height = [super getHeight:textCellData withWidth:width];
    if (textCellData.bottomContainerSize.height > 0) {
        height += textCellData.bottomContainerSize.height + kScale375(6);
    }
    return height;
}

+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUITextMessageCellData.class], @"data must be kind of TUITextMessageCellData");
    TUITextMessageCellData *textCellData = (TUITextMessageCellData *)data;

    UIFont *textFont = textCellData.direction == MsgDirectionIncoming ? self.incommingTextFont : self.outgoingTextFont;
    NSAttributedString *attributeString = [textCellData getAttributedString:textFont];
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil];
    CGSize size = rect.size;

    CGRect rect2 = [attributeString boundingRectWithSize:CGSizeMake(MAXFLOAT, [textFont lineHeight])
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 context:nil];
    CGSize size2 = rect2.size;

    // 如果有多行，判断下最后一行的字体宽度是否超过了消息状态的位置，如果超过，消息状态换行
    // 如果只有一行，直接加上消息状态的宽度
    int max_width = size.height > [textFont lineHeight] ? size.width : TTextMessageCell_Text_Width_Max;
    if ((int)size2.width / max_width > 0) {
        if ((int)size2.width % max_width == 0 || (int)size2.width % max_width + textCellData.msgStatusSize.width > max_width) {
            size.height += textCellData.msgStatusSize.height;
        }
    } else {
        size.width += textCellData.msgStatusSize.width + kScale390(10);
    }

    textCellData.textSize = size;
    CGFloat y = textCellData.cellLayout.bubbleInsets.top + [TUIBubbleMessageCell_Minimalist getBubbleTop:textCellData];
    textCellData.textOrigin = CGPointMake(textCellData.cellLayout.bubbleInsets.left, y);

    size.height += textCellData.cellLayout.bubbleInsets.top + textCellData.cellLayout.bubbleInsets.bottom;
    size.width += textCellData.cellLayout.bubbleInsets.left + textCellData.cellLayout.bubbleInsets.right;

    if (textCellData.direction == MsgDirectionIncoming) {
        size.height = MAX(size.height, TUIBubbleMessageCell_Minimalist.incommingBubble.size.height);
    } else {
        size.height = MAX(size.height, TUIBubbleMessageCell_Minimalist.outgoingBubble.size.height);
    }

    return size;
}

@end


@implementation TUITextMessageCell_Minimalist (TUILayoutConfiguration)

+ (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

static UIColor *gOutgoingTextColor;

+ (UIColor *)outgoingTextColor {
    if (!gOutgoingTextColor) {
        gOutgoingTextColor = TUIChatDynamicColor(@"chat_text_message_send_text_color", @"#000000");
    }
    return gOutgoingTextColor;
}

+ (void)setOutgoingTextColor:(UIColor *)outgoingTextColor {
    gOutgoingTextColor = outgoingTextColor;
}

static UIFont *gOutgoingTextFont;

+ (UIFont *)outgoingTextFont {
    if (!gOutgoingTextFont) {
        gOutgoingTextFont = [UIFont systemFontOfSize:16];
    }
    return gOutgoingTextFont;
}

+ (void)setOutgoingTextFont:(UIFont *)outgoingTextFont {
    gOutgoingTextFont = outgoingTextFont;
}

static UIColor *gIncommingTextColor;

+ (UIColor *)incommingTextColor {
    if (!gIncommingTextColor) {
        gIncommingTextColor = TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000");
    }
    return gIncommingTextColor;
}

+ (void)setIncommingTextColor:(UIColor *)incommingTextColor {
    gIncommingTextColor = incommingTextColor;
}

static UIFont *gIncommingTextFont;

+ (UIFont *)incommingTextFont {
    if (!gIncommingTextFont) {
        gIncommingTextFont = [UIFont systemFontOfSize:16];
    }
    return gIncommingTextFont;
}

+ (void)setIncommingTextFont:(UIFont *)incommingTextFont {
    gIncommingTextFont = incommingTextFont;
}

+ (void)onThemeChanged {
    gOutgoingTextColor = nil;
    gIncommingTextColor = nil;
}

@end
