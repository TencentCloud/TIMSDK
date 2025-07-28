//
//  TUITextMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextMessageCell.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIGlobalization.h>
#import "TUIFaceView.h"
#import <TUICore/UIColor+TUIHexColor.h>

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface TUITextMessageCell ()<TUITextViewDelegate>
@end

@implementation TUITextMessageCell

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
        self.textView.tuiTextViewDelegate = self;
        self.bubbleView.userInteractionEnabled = YES;
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

- (void)onLongPressTextViewMessage:(UITextView *)textView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onLongPressMessage:)]) {
        [self.delegate onLongPressMessage:self];
    }
}

// Override
- (void)notifyBottomContainerReadyOfData:(TUIMessageCellData *)cellData {
    NSDictionary *param = @{TUICore_TUIChatExtension_BottomContainer_CellData : self.textData};
    [TUICore raiseExtension:TUICore_TUIChatExtension_BottomContainer_ClassicExtensionID parentView:self.bottomContainer param:param];
}

- (void)fillWithData:(TUITextMessageCellData *)data {
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
    self.textView.attributedText = [data getContentAttributedString:textFont];
    self.textView.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
    self.textView.textColor = textColor;
    self.textView.font = textFont;

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bubbleView.mas_leading).mas_offset(self.textData.textOrigin.x);
        make.top.mas_equalTo(self.bubbleView.mas_top).mas_offset(self.textData.textOrigin.y);
        make.size.mas_equalTo(self.textData.textSize);
    }];

    if (self.voiceReadPoint.hidden == NO) {
        [self.voiceReadPoint mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.top.mas_equalTo(self.bubbleView);
          make.leading.mas_equalTo(self.bubbleView.mas_trailing).mas_offset(1);
          make.size.mas_equalTo(CGSizeMake(5, 5));
        }];
    }
    
    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent ) {
        [self.securityStrikeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.textView.mas_bottom);
            make.width.mas_equalTo(self.bubbleView);
            make.bottom.mas_equalTo(self.container).mas_offset(- self.messageData.messageContainerAppendSize.height);
        }];
    }
    [self layoutBottomContainer];
    
}

- (void)layoutBottomContainer {
    if (CGSizeEqualToSize(self.textData.bottomContainerSize, CGSizeZero)) {
        return;
    }

    CGSize size = self.textData.bottomContainerSize;

    [self.bottomContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.textData.direction == MsgDirectionIncoming) {
            make.leading.mas_equalTo(self.container.mas_leading);
        }
        else {
            make.trailing.mas_equalTo(self.container.mas_trailing);
        }
        make.top.mas_equalTo(self.container.mas_bottom).offset(6);
        make.size.mas_equalTo(size);
    }];

    CGFloat repliesBtnTextWidth = self.messageModifyRepliesButton.frame.size.width;
    if (!self.messageModifyRepliesButton.hidden) {
        [self.messageModifyRepliesButton mas_remakeConstraints:^(MASConstraintMaker *make) {
          if (self.textData.direction == MsgDirectionIncoming) {
              make.leading.mas_equalTo(self.container.mas_leading);
          } else {
              make.trailing.mas_equalTo(self.container.mas_trailing);
          }
          make.top.mas_equalTo(self.bottomContainer.mas_bottom);
          make.size.mas_equalTo(CGSizeMake(repliesBtnTextWidth + 10, 30));
        }];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kTUIChatPopMenuWillHideNotification" object:nil];
    }
}


#pragma mark - TUIMessageCellProtocol

+ (CGFloat)getEstimatedHeight:(TUIMessageCellData *)data {
    return 60.f;
}

+ (CGFloat)getHeight:(TUIMessageCellData *)data withWidth:(CGFloat)width {
    CGFloat height = [super getHeight:data withWidth:width];
    if (data.bottomContainerSize.height > 0) {
        height += data.bottomContainerSize.height + kScale375(6);
    }
    return height;
}

static CGSize gMaxTextSize;
+ (void)setMaxTextSize:(CGSize)maxTextSz {
    gMaxTextSize = maxTextSz;
}
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUITextMessageCellData.class], @"data must be kind of TUITextMessageCellData");
    TUITextMessageCellData *textCellData = (TUITextMessageCellData *)data;

    NSAttributedString *attributeString = [textCellData getContentAttributedString:
                                           data.direction == MsgDirectionIncoming ? self.incommingTextFont : self.outgoingTextFont];
    
    if (CGSizeEqualToSize(gMaxTextSize, CGSizeZero)) {
        gMaxTextSize = CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT);
    }
    CGSize contentSize = [textCellData getContentAttributedStringSize:attributeString maxTextSize:gMaxTextSize];
    textCellData.textSize = contentSize;

    CGPoint textOrigin = CGPointMake(textCellData.cellLayout.bubbleInsets.left,
                                     textCellData.cellLayout.bubbleInsets.top);
    textCellData.textOrigin = textOrigin;
    
    CGFloat height = contentSize.height;
    CGFloat width = contentSize.width;

    height += textCellData.cellLayout.bubbleInsets.top;
    height += textCellData.cellLayout.bubbleInsets.bottom;
    
    width += textCellData.cellLayout.bubbleInsets.left;
    width += textCellData.cellLayout.bubbleInsets.right;

    if (textCellData.direction == MsgDirectionIncoming) {
        height = MAX(height, TUIBubbleMessageCell.incommingBubble.size.height);
    } else {
        height = MAX(height, TUIBubbleMessageCell.outgoingBubble.size.height);
    }
    
    BOOL hasRiskContent = textCellData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        width = MAX(width, 200);// width must more than  TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrike)
        height += kTUISecurityStrikeViewTopLineMargin;
        height += kTUISecurityStrikeViewTopLineToBottom;
    }

    CGSize size = CGSizeMake(width, height);
    return size;
}

@end


@implementation TUITextMessageCell (TUILayoutConfiguration)

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
