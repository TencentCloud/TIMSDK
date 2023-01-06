//
//  TUITextMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUITextMessageCellData.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"
#import "NSString+TUIEmoji.h"
#import "TUIThemeManager.h"

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface TUITextMessageCellData()

@property (nonatomic, assign) CGSize textSize;
@property (nonatomic, assign) CGPoint textOrigin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat containerWidth;

@end

@implementation TUITextMessageCellData

+ (void)initialize
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    TUITextMessageCellData *textData = [[TUITextMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    textData.content = message.textElem.text;
    textData.reuseId = TTextMessageCell_ReuseId;
    textData.status = Msg_Status_Init;
    return textData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    NSString *content = message.textElem.text;
    return content.getLocalizableStringWithFaceContent;
}

- (BOOL)canTranslate {
    return YES;
}

- (Class)getReplyQuoteViewDataClass
{
    return NSClassFromString(@"TUITextReplyQuoteViewData");
}

- (Class)getReplyQuoteViewClass
{
    return NSClassFromString(@"TUITextReplyQuoteView");
}

- (instancetype)initWithDirection:(TMsgDirection)direction
{
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
    return 60.f;
}

// Override, the height of whole tableview cell.
- (CGFloat)heightOfWidth:(CGFloat)width
{
    CGFloat height = [super heightOfWidth:width];
    
    // load translationView's saved data to render translationView
    if ([self.translationViewData shouldLoadSavedData]) {
        [self.translationViewData setMessage:self.innerMessage];
        [self.translationViewData loadSavedData];
    }
    [self.translationViewData calcSize];
    
    if (![self.translationViewData isHidden]) {
        height += self.translationViewData.size.height + 6;
    }

    return height;
}

// Override, the size of bubble content.
- (CGSize)contentSize
{
    if (!CGSizeEqualToSize(self.size, CGSizeZero)) {
        return self.size;
    }
    
    static CGSize maxTextSize;
    if (CGSizeEqualToSize(maxTextSize, CGSizeZero)) {
        maxTextSize = CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT);
    }
    CGRect rect = [self.attributedString boundingRectWithSize:maxTextSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    CGFloat width = CGFLOAT_CEIL(rect.size.width);
    CGFloat height = CGFLOAT_CEIL(rect.size.height);
    
    self.textSize = CGSizeMake(width, height);
    
    static CGPoint textOrigin;
    if (CGPointEqualToPoint(CGPointZero, textOrigin)) {
        textOrigin = CGPointMake(self.cellLayout.bubbleInsets.left, self.cellLayout.bubbleInsets.top + self.bubbleTop);
    }
    self.textOrigin = textOrigin;

    height += self.cellLayout.bubbleInsets.top + self.cellLayout.bubbleInsets.bottom;
    width += self.cellLayout.bubbleInsets.left+self.cellLayout.bubbleInsets.right;

    if (self.direction == MsgDirectionIncoming) {
        height = MAX(height, [TUIBubbleMessageCellData incommingBubble].size.height);
    } else {
        height = MAX(height, [TUIBubbleMessageCellData outgoingBubble].size.height);
    }
    
    self.size = CGSizeMake(width, height);
    return self.size;
}

- (NSMutableAttributedString *)attributedString
{
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
                if (self.innerMessage.isSelf) {
                    image = TUIChatCommonBundleImage(@"video_call_self");
                } else {
                    image = TUIChatCommonBundleImage(@"video_call");
                }
            }
            attchment.image = image;
            attchment.bounds = CGRectMake(0, -(self.textFont.lineHeight-self.textFont.pointSize)/2, 16, 16);
            NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
            NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName: self.textFont}];
            if (self.innerMessage.isSelf) {
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

#pragma mark - Color
static UIColor *sOutgoingTextColor;

+ (UIColor *)outgoingTextColor
{
    if (!sOutgoingTextColor) {
        sOutgoingTextColor = TUIChatDynamicColor(@"chat_text_message_send_text_color", @"#000000");
    }
    return sOutgoingTextColor;
}

+ (void)setOutgoingTextColor:(UIColor *)outgoingTextColor
{
    sOutgoingTextColor = outgoingTextColor;
}

static UIFont *sOutgoingTextFont;

+ (UIFont *)outgoingTextFont
{
    if (!sOutgoingTextFont) {
        sOutgoingTextFont = [UIFont systemFontOfSize:16];
    }
    return sOutgoingTextFont;
}

+ (void)setOutgoingTextFont:(UIFont *)outgoingTextFont
{
    sOutgoingTextFont = outgoingTextFont;
}

static UIColor *sIncommingTextColor;

+ (UIColor *)incommingTextColor
{
    if (!sIncommingTextColor) {
        sIncommingTextColor = TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000");
    }
    return sIncommingTextColor;
}

+ (void)setIncommingTextColor:(UIColor *)incommingTextColor
{
    sIncommingTextColor = incommingTextColor;
}

static UIFont *sIncommingTextFont;

+ (UIFont *)incommingTextFont
{
    if (!sIncommingTextFont) {
        sIncommingTextFont = [UIFont systemFontOfSize:16];
    }
    return sIncommingTextFont;
}

+ (void)setIncommingTextFont:(UIFont *)incommingTextFont
{
    sIncommingTextFont = incommingTextFont;
}

+ (void)onThemeChanged
{
    sOutgoingTextColor = nil;
    sIncommingTextColor = nil;
}

@end
