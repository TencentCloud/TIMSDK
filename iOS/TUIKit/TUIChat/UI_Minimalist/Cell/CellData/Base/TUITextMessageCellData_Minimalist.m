//
//  TUITextMessageCellData_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextMessageCellData_Minimalist.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIMessageCellLayout.h>
#import <TUICore/TUIThemeManager.h>

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface TUITextMessageCellData_Minimalist ()
@property(nonatomic, assign) CGSize textSize;
@property(nonatomic, assign) CGPoint textOrigin;
@property(nonatomic, assign) CGSize size;

@end

@implementation TUITextMessageCellData_Minimalist

+ (void)initialize {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    TUITextMessageCellData_Minimalist *textData =
        [[TUITextMessageCellData_Minimalist alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    textData.content = message.textElem.text;
    textData.reuseId = TTextMessageCell_ReuseId;
    textData.status = Msg_Status_Init;
    return textData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSString *content = message.textElem.text;
    return content.getLocalizableStringWithFaceContent;
}

- (Class)getReplyQuoteViewDataClass {
    return NSClassFromString(@"TUITextReplyQuoteViewData_Minimalist");
}

- (Class)getReplyQuoteViewClass {
    return NSClassFromString(@"TUITextReplyQuoteView_Minimalist");
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _textColor = [[self class] incommingTextColor];
            _textFont = [[self class] incommingTextFont];
            self.cellLayout = [TUIMessageCellLayout incommingTextMessageLayout];
        } else {
            _textColor = [[self class] outgoingTextColor];
            _textFont = [[self class] outgoingTextFont];
            self.cellLayout = [TUIMessageCellLayout outgoingTextMessageLayout];
        }
    }
    return self;
}

- (CGFloat)estimatedHeight {
    return 44.f;
}

// Override, the height of whole tableview cell.
- (CGFloat)heightOfWidth:(CGFloat)width {
    CGFloat height = [super heightOfWidth:width];

    if (self.bottomContainerSize.height > 0) {
        height += self.bottomContainerSize.height + 6;
    }
    return height;
}

- (CGSize)contentSize {
    if (!CGSizeEqualToSize(self.size, CGSizeZero)) {
        return self.size;
    }

    CGRect rect = [self.attributedString boundingRectWithSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      context:nil];
    CGSize size = rect.size;

    CGRect rect2 = [self.attributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, [self.textFont lineHeight])
                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                       context:nil];
    CGSize size2 = rect2.size;

    // 如果有多行，判断下最后一行的字体宽度是否超过了消息状态的位置，如果超过，消息状态换行
    // 如果只有一行，直接加上消息状态的宽度
    int max_width = size.height > [self.textFont lineHeight] ? size.width : TTextMessageCell_Text_Width_Max;
    if ((int)size2.width / max_width > 0) {
        if ((int)size2.width % max_width == 0 || (int)size2.width % max_width + self.msgStatusSize.width > max_width) {
            size.height += self.msgStatusSize.height;
        }
    } else {
        size.width += self.msgStatusSize.width + kScale390(10);
    }

    self.textSize = size;
    self.textOrigin = CGPointMake(self.cellLayout.bubbleInsets.left, self.cellLayout.bubbleInsets.top + self.bubbleTop);

    size.height += self.cellLayout.bubbleInsets.top + self.cellLayout.bubbleInsets.bottom;
    size.width += self.cellLayout.bubbleInsets.left + self.cellLayout.bubbleInsets.right;

    if (self.direction == MsgDirectionIncoming) {
        size.height = MAX(size.height, [TUIBubbleMessageCellData_Minimalist incommingBubble].size.height);
    } else {
        size.height = MAX(size.height, [TUIBubbleMessageCellData_Minimalist outgoingBubble].size.height);
    }

    self.size = size;
    return self.size;
}

- (NSMutableAttributedString *)attributedString {
    if (!_attributedString) {
        _emojiLocations = [NSMutableArray array];
        _attributedString = [self.content getFormatEmojiStringWithFont:self.textFont emojiLocations:_emojiLocations];
        if (self.isAudioCall || self.isVideoCall) {
            NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
            UIImage *image = nil;
            if (self.isAudioCall) {
                image = TUIChatCommonBundleImage(@"audio_call");
            }
            if (self.isVideoCall) {
                if (self.isCaller) {
                    image = TUIChatCommonBundleImage(@"video_call_self");
                } else {
                    image = TUIChatCommonBundleImage(@"video_call");
                }
            }
            attchment.image = image;
            attchment.bounds = CGRectMake(0, -(self.textFont.lineHeight - self.textFont.pointSize) / 2, 16, 16);
            NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
            NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName : self.textFont}];
            if (self.isCaller) {
                [_attributedString appendAttributedString:spaceString];
                [_attributedString appendAttributedString:imageString];
            } else {
                [_attributedString insertAttributedString:spaceString atIndex:0];
                [_attributedString insertAttributedString:imageString atIndex:0];
            }
        }
    }
    return _attributedString;
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
