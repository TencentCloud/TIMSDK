//
//  TUIInputPreviewBar.m
//  TUIChat
//
//  Created by harvy on 2021/11/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReplyPreviewBar.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIReplyPreviewBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = TUIChatDynamicColor(@"chat_input_controller_bg_color", @"#EBF0F6");
    [self addSubview:self.titleLabel];
    [self addSubview:self.closeButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.closeButton.mm_width(16).mm_height(16);
    self.closeButton.mm_centerY = self.mm_centerY;
    self.closeButton.mm_right(16.0);

    self.titleLabel.mm_x = 16.0;
    self.titleLabel.mm_y = 10;
    self.titleLabel.mm_w = self.closeButton.mm_x - 10 - 16;
    self.titleLabel.mm_h = self.mm_h - 20;
}

- (void)onClose:(UIButton *)closeButton {
    if (self.onClose) {
        self.onClose();
    }
}

- (void)setPreviewData:(TUIReplyPreviewData *)previewData {
    _previewData = previewData;

    NSString *abstract = [TUIReplyPreviewData displayAbstract:previewData.type abstract:previewData.msgAbstract withFileName:YES isRisk:NO];
    _titleLabel.text = [[NSString stringWithFormat:@"%@: %@", previewData.sender, abstract] getLocalizableStringWithFaceContent];
    _titleLabel.lineBreakMode = previewData.type == (NSInteger)V2TIM_ELEM_TYPE_FILE ? NSLineBreakByTruncatingMiddle : NSLineBreakByTruncatingTail;
}

- (void)setPreviewReferenceData:(TUIReferencePreviewData *)previewReferenceData {
    _previewReferenceData = previewReferenceData;

    NSString *abstract = [TUIReferencePreviewData displayAbstract:previewReferenceData.type
                                                         abstract:previewReferenceData.msgAbstract
                                                     withFileName:YES
                                                           isRisk:NO];
    _titleLabel.text = [[NSString stringWithFormat:@"%@: %@", previewReferenceData.sender, abstract] getLocalizableStringWithFaceContent];
    _titleLabel.lineBreakMode = previewReferenceData.type == (NSInteger)V2TIM_ELEM_TYPE_FILE ? NSLineBreakByTruncatingMiddle : NSLineBreakByTruncatingTail;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor colorWithRed:143 / 255.0 green:150 / 255.0 blue:160 / 255.0 alpha:1 / 1.0];
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:TUIChatCommonBundleImage(@"icon_close") forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton sizeToFit];
    }
    return _closeButton;
}

@end

@implementation TUIReferencePreviewBar

- (void)layoutSubviews {
    [super layoutSubviews];

    self.closeButton.mm_right(16.0);
    self.closeButton.frame = CGRectMake(self.closeButton.frame.origin.x, (self.frame.size.height - 16) * 0.5, 16, 16);

    self.titleLabel.mm_x = 16.0;
    self.titleLabel.mm_y = 10;
    self.titleLabel.mm_w = self.closeButton.mm_x - 10 - 16;
    self.titleLabel.mm_h = self.mm_h - 20;
}
@end
