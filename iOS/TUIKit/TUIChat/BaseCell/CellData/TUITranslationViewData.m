//
//  TUITranslationViewData.m
//  TUIChat
//

#import "TUITranslationViewData.h"
#import "TUIDefine.h"
#import "NSString+TUIEmoji.h"

static NSString * const kKeyTranslationText = @"translation";
static NSString * const kKeyTranslationViewStatus = @"translation_view_status";
static NSString * const kKeyTranslationViewContainerWidth = @"container_width";

@interface TUITranslationViewData()

@property (nonatomic, assign) CGFloat containerWidth;
@property (nonatomic, strong) V2TIMMessage *message;
@property (nonatomic, assign, readwrite) CGSize size;

@end

@implementation TUITranslationViewData

#pragma mark - Public
- (void)setContainerWidth:(CGFloat)width {
    _containerWidth = width;
    [self saveContainerWidth:width];
}

- (void)setMessage:(V2TIMMessage *)message {
    if (_message == message) {
        return;
    }
    _message = message;
}

- (void)loadSavedData {
    if (self.message.localCustomData.length == 0) {
        return;
    }
    NSDictionary *dict = [TUITool jsonData2Dictionary:self.message.localCustomData];
    if ([dict.allKeys containsObject:kKeyTranslationText]) {
        self.text = dict[kKeyTranslationText];
    }
    if ([dict.allKeys containsObject:kKeyTranslationViewStatus]) {
        self.status = [dict[kKeyTranslationViewStatus] integerValue];
    } else {
        self.status = TUITranslationViewStatusHidden;
    }
    if ([dict.allKeys containsObject:kKeyTranslationViewContainerWidth]) {
        self.containerWidth = [dict[kKeyTranslationViewContainerWidth] floatValue];
    }
}

- (void)calcSize {
    CGFloat minTextWidth = 164;
    CGFloat maxTextWidth = Screen_Width * 0.68;
    CGFloat actualTextWidth = self.containerWidth - 20;
    CGFloat tipsHeight = 20;
    CGFloat tipsBottomMargin = 10;
    CGFloat oneLineTextHeight = 22;
    CGFloat commonMargins = 10 * 2;
    
    // Translation is processing, return the size of an empty cell including loading animation.
    if (self.status == TUITranslationViewStatusLoading) {
        self.size = CGSizeMake(self.containerWidth, oneLineTextHeight + commonMargins);
        return;
    }
    
    NSAttributedString *attrStr = [self.text getAdvancedFormatEmojiStringWithFont:[UIFont systemFontOfSize:16]
                                                                        textColor:[UIColor grayColor]
                                                                   emojiLocations:nil];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];

    // Translation is finished.
    // Calc the size according to the actual text width.
    CGRect textRect = [attrStr boundingRectWithSize:CGSizeMake(actualTextWidth, MAXFLOAT)
                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
    if (textRect.size.height < 30) {
        // Result is only one line text.
        self.size = CGSizeMake(MAX(textRect.size.width, minTextWidth) + commonMargins,
                               MAX(textRect.size.height, oneLineTextHeight) + commonMargins + tipsHeight + tipsBottomMargin);
        return;
    }
    
    // Result is more than one line, so recalc size using maxTextWidth.
    textRect = [attrStr boundingRectWithSize:CGSizeMake(maxTextWidth, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     context:nil];
    self.size = CGSizeMake(MAX(textRect.size.width, minTextWidth) + commonMargins,
                           MAX(textRect.size.height, oneLineTextHeight) + commonMargins + tipsHeight + tipsBottomMargin);
}

- (BOOL)isHidden {
    NSArray *hiddenStatus = @[@(TUITranslationViewStatusUnknown), @(TUITranslationViewStatusHidden)];
    return [hiddenStatus containsObject:@(self.status)];
}

- (BOOL)shouldLoadSavedData {
    return self.status == TUITranslationViewStatusUnknown;
}

#pragma mark - Private
- (void)saveText:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    [self saveToLocalCustomDataOfKey:kKeyTranslationText value:text];
}

- (void)saveStatus:(TUITranslationViewStatus)status {
    [self saveToLocalCustomDataOfKey:kKeyTranslationViewStatus value:@(status)];
}

- (void)saveContainerWidth:(CGFloat)width {
    if (width == 0) {
        return;
    }
    [self saveToLocalCustomDataOfKey:kKeyTranslationViewContainerWidth value:@(width)];
}

- (void)saveToLocalCustomDataOfKey:(NSString *)key value:(id)value {
    if (key.length == 0 || value == nil) {
        return;
    }
    NSData *customData = self.message.localCustomData;
    NSMutableDictionary *dict = [[TUITool jsonData2Dictionary:customData] mutableCopy];
    if (dict == nil) {
        dict = [[NSMutableDictionary alloc] init];
    }
    dict[key] = value;
    [self.message setLocalCustomData:[TUITool dictionary2JsonData:dict]];
}

#pragma mark - Access method
- (void)setStatus:(TUITranslationViewStatus)status {
    if (_status == status) {
        return;
    }
    _status = status;
    if (status != TUITranslationViewStatusLoading) {
        [self saveStatus:status];
    }
}

- (void)setText:(NSString *)text {
    if (_text == text) {
        return;
    }
    _text = text;
    [self saveText:text];
}

@end
