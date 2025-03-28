// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaSubtitleEditView.h"
#import <Masonry/Masonry.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMultimediaPlugin/TUIMultimediaColorPanel.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"

@interface TUIMultimediaSubtitleEditView () <TUIMultimediaColorPanelDelegate, UITextViewDelegate> {
    UIButton *_btnOk;
    UIButton *_btnCancel;
    UITextView *_textView;
    TUIMultimediaColorPanel *_colorPanel;
}

@end

@implementation TUIMultimediaSubtitleEditView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _subtitleInfo = [[TUIMultimediaSubtitleInfo alloc] init];
        [self initUI];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)activate {
    [_textView becomeFirstResponder];
}

- (void)initUI {
    self.backgroundColor = TUIMultimediaPluginDynamicColor(@"editor_popup_view_bg_color", @"#000000BF");

    _btnOk = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnOk setTitle:[TUIMultimediaCommon localizedStringForKey:@"ok"] forState:UIControlStateNormal];
    [_btnOk setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnOk.titleLabel.font = [UIFont systemFontOfSize:20];
    [_btnOk addTarget:self action:@selector(onOk) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnOk];

    _btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btnCancel setTitle:[TUIMultimediaCommon localizedStringForKey:@"cancel"] forState:UIControlStateNormal];
    [_btnCancel setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _btnCancel.titleLabel.font = [UIFont systemFontOfSize:20];
    _btnCancel.titleLabel.textColor = UIColor.whiteColor;
    [_btnCancel addTarget:self action:@selector(onCancel) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnCancel];

    _textView = [[UITextView alloc] init];
    _textView.backgroundColor = UIColor.clearColor;
    _textView.font = [UIFont systemFontOfSize:20];
    _textView.text = _subtitleInfo.text;
    _textView.textColor = _subtitleInfo.color;
    _textView.delegate = self;
    [self addSubview:_textView];

    _colorPanel = [[TUIMultimediaColorPanel alloc] init];
    _colorPanel.delegate = self;
    [self addSubview:_colorPanel];

    [_btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
      make.right.equalTo(self).inset(30);
      make.width.mas_greaterThanOrEqualTo(100);
      make.height.mas_greaterThanOrEqualTo(50);
    }];
    [_btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
      make.left.equalTo(self).inset(30);
      make.width.mas_greaterThanOrEqualTo(100);
      make.height.mas_greaterThanOrEqualTo(50);
    }];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.equalTo(self).inset(50);
      make.top.equalTo(_btnOk.mas_bottom).inset(50);
      make.bottom.equalTo(_colorPanel.mas_top).inset(10);
    }];
    [_colorPanel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.right.equalTo(self).inset(10);
      make.height.mas_equalTo(32);
      make.bottom.equalTo(self);
    }];
}

#pragma mark - Actions
- (void)onOk {
    NSMutableString *wrappedText = [NSMutableString string];
    NSString *text = _textView.text;
    NSLayoutManager *layoutManager = _textView.layoutManager;
    NSUInteger numberOfLines, index;
    NSUInteger numberOfGlyphs = [layoutManager numberOfGlyphs];
    BOOL lastLineBreak = NO;
    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++) {
        NSRange lineRange;
        [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        //        NSLog(@"TUIMultimedia Subtitle Line:%@", [text substringWithRange:lineRange]);
        index = NSMaxRange(lineRange);
        NSString *line = [text substringWithRange:lineRange];
        if (numberOfLines != 0 && !lastLineBreak) {
            [wrappedText appendString:@"\n"];
        }
        [wrappedText appendString:line];
        lastLineBreak = [line containsString:@"\n"];
    }
    _subtitleInfo.text = _textView.text;
    _subtitleInfo.wrappedText = wrappedText;
    [_delegate subtitleEditViewOnOk:self];
}

- (void)onCancel {
    [_delegate subtitleEditViewOnCancel:self];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [_colorPanel mas_updateConstraints:^(MASConstraintMaker *make) {
      make.bottom.equalTo(self).offset(-CGRectGetHeight(rect));
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self onCancel];
}

#pragma mark - UITextViewDelegate protocol
- (void)onColorPanel:(TUIMultimediaColorPanel *)panel selectColor:(UIColor *)color {
    _subtitleInfo.color = color;
    _textView.textColor = color;
}

#pragma mark - Setters
- (void)setSubtitleInfo:(TUIMultimediaSubtitleInfo *)subtitleInfo {
    _subtitleInfo = subtitleInfo;
    _textView.textColor = _subtitleInfo.color;
    _textView.text = subtitleInfo.text;
    _colorPanel.selectedColor = _subtitleInfo.color;
}

@end
