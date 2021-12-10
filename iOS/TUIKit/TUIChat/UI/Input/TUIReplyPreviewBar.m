//
//  TUIInputPreviewBar.m
//  TUIChat
//
//  Created by harvy on 2021/11/9.
//

#import "TUIReplyPreviewBar.h"
#import "TUIDarkModel.h"
#import "TUIDefine.h"
#import "NSString+emoji.h"

@implementation TUIReplyPreviewData

+ (NSString *)displayAbstract:(NSInteger)type abstract:(NSString *)abstract withFileName:(BOOL)withFilename
{
    NSString *text = abstract;
    if (type == V2TIM_ELEM_TYPE_IMAGE) {
        text = TUIKitLocalizableString(TUIkitMessageTypeImage);
    } else if (type == V2TIM_ELEM_TYPE_VIDEO) {
        text = TUIKitLocalizableString(TUIkitMessageTypeVideo);
    } else if (type == V2TIM_ELEM_TYPE_SOUND) {
        text = TUIKitLocalizableString(TUIKitMessageTypeVoice);
    } else if (type == V2TIM_ELEM_TYPE_FACE) {
        text = TUIKitLocalizableString(TUIKitMessageTypeAnimateEmoji);
    } else if (type == V2TIM_ELEM_TYPE_FILE) {
        if (withFilename) {
            text = [NSString stringWithFormat:@"%@%@", TUIKitLocalizableString(TUIkitMessageTypeFile), abstract];;
        } else {
            text = TUIKitLocalizableString(TUIkitMessageTypeFile);
        }
    }
    return text;
}

@end

@implementation TUIReplyPreviewBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];
    [self addSubview:self.titleLabel];
    [self addSubview:self.closeButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.closeButton.mm_width(16).mm_height(16);
    self.closeButton.mm_centerY = self.mm_centerY;
    self.closeButton.mm_right(16.0);
    
    self.titleLabel.mm_x = 16.0;
    self.titleLabel.mm_y = 10;
    self.titleLabel.mm_w = self.closeButton.mm_x - 10 - 16;
    self.titleLabel.mm_h = self.mm_h - 20;
}

- (void)onClose:(UIButton *)closeButton
{
    if (self.onClose) {
        self.onClose();
    }
}

- (void)setPreviewData:(TUIReplyPreviewData *)previewData
{
    _previewData = previewData;
    
    NSString *abstract = [TUIReplyPreviewData displayAbstract:previewData.type abstract:previewData.msgAbstract withFileName:YES];
    _titleLabel.text = [[NSString stringWithFormat:@"%@: %@", previewData.sender, abstract] getLocalizableStringWithFaceContent];
    _titleLabel.lineBreakMode = previewData.type == (NSInteger)V2TIM_ELEM_TYPE_FILE ? NSLineBreakByTruncatingMiddle : NSLineBreakByTruncatingTail;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        // TODO: 暗黑模式适配
        _titleLabel.textColor = [UIColor colorWithRed:143/255.0 green:150/255.0 blue:160/255.0 alpha:1/1.0];
    }
    return _titleLabel;
}

- (UIButton *)closeButton
{
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        // TODO: 暗黑模式适配
        [_closeButton setImage:[UIImage d_imageNamed:@"icon_close" bundle:TUIChatBundle] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton sizeToFit];
    }
    return _closeButton;
}

@end
