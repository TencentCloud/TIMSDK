//
//  TUITextMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextMessageCellData.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface TUITextMessageCellData ()

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGFloat containerWidth;

@property(nonatomic, strong) NSMutableAttributedString *attributedString;

@end

@implementation TUITextMessageCellData
{
    NSString *_content;
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

- (Class)getReplyQuoteViewDataClass {
    return NSClassFromString(@"TUITextReplyQuoteViewData");
}

- (Class)getReplyQuoteViewClass {
    return NSClassFromString(@"TUITextReplyQuoteView");
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            self.cellLayout = [TUIMessageCellLayout incommingTextMessageLayout];
        } else {
            self.cellLayout = [TUIMessageCellLayout outgoingTextMessageLayout];
        }
    }
    return self;
}

- (void)setContent:(NSString *)content {
    if (![_content isEqualToString:content]) {
        _content = content;
        _attributedString = nil;
    }
}

- (NSString *)content {
    return _content;
}

- (NSAttributedString *)getContentAttributedString:(UIFont *)textFont {
    if (!_attributedString) {
        _emojiLocations = [NSMutableArray array];
        _attributedString = [self.content getFormatEmojiStringWithFont:textFont emojiLocations:_emojiLocations];
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
            attchment.bounds = CGRectMake(0, -(textFont.lineHeight - textFont.pointSize) / 2, 16, 16);
            NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
            NSAttributedString *spaceString = [[NSAttributedString alloc] initWithString:@"  " attributes:@{NSFontAttributeName : textFont}];
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

- (CGSize)getContentAttributedStringSize:(NSAttributedString *)attributeString maxTextSize:(CGSize)maxTextSize {
    CGRect rect = [attributeString boundingRectWithSize:maxTextSize
                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil];

    CGFloat width = CGFLOAT_CEIL(rect.size.width);
    CGFloat height = CGFLOAT_CEIL(rect.size.height);
    return CGSizeMake(width, height);
}

@end
