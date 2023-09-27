//
//  TUIMessageMultiChooseView.m
//  Pods
//
//  Created by harvy on 2020/11/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageMultiChooseView_Minimalist.h"
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import <TUICore/UIView+TUILayout.h>
#import <TIMCommon/TIMDefine.h>

@interface TUIMessageMultiChooseView_Minimalist ()

@property(nonatomic, strong) CALayer *separtorLayer;

@end

@implementation TUIMessageMultiChooseView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    } else {
        return hitView;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat toolHeight = 44;
    CGFloat menuHeight = 54;
    CGFloat centerTopOffset = 0;
    CGFloat centerBottomOffset = 0;
    if (@available(iOS 11.0, *)) {
        toolHeight += self.safeAreaInsets.top;
        menuHeight += self.safeAreaInsets.bottom;
        centerTopOffset = self.safeAreaInsets.top;
        centerBottomOffset = self.safeAreaInsets.bottom;
    }

    self.toolView.frame = CGRectMake(0, 0, self.bounds.size.width, toolHeight);
    self.menuView.frame = CGRectMake(0, self.bounds.size.height - menuHeight, self.bounds.size.width, menuHeight);
    self.separtorLayer.frame = CGRectMake(0, 0, self.menuView.mm_w, 1);

    // toolView
    {
        CGFloat centerY = 0.5 * (self.toolView.bounds.size.height - self.cancelButton.bounds.size.height);
        self.cancelButton.frame = CGRectMake(10, centerY += 0.5 * centerTopOffset, self.cancelButton.bounds.size.width, self.cancelButton.bounds.size.height);

        [self.titleLabel sizeToFit];
        self.titleLabel.center = self.toolView.center;
        CGRect titleRect = self.self.titleLabel.frame;
        titleRect.origin.y += 0.5 * centerTopOffset;
        self.titleLabel.frame = titleRect;
    }

    // menuView
    {
        CGFloat width = self.menuView.bounds.size.width;
        self.relayButton.frame = CGRectMake(kScale390(23), kScale390(17), kScale390(16), kScale390(16));
        self.deleteButton.frame =
            CGRectMake(self.relayButton.frame.origin.x + self.relayButton.frame.size.width + kScale390(17), kScale390(17), kScale390(16), kScale390(16));
        [self.selectedCountLabel sizeToFit];
        CGFloat labelWidth = self.selectedCountLabel.frame.size.width;
        labelWidth = labelWidth + 10;
        self.selectedCountLabel.frame = CGRectMake((width - labelWidth) * 0.5, kScale390(14), labelWidth, kScale390(30));
        self.bottomCancelButton.frame = CGRectMake((width - kScale390(50) - kScale390(23)), kScale390(14), kScale390((50)), kScale390(30));
    }
    if(isRTL()) {
        for (UIView *subview in self.toolView.subviews) {
            [subview resetFrameToFitRTL];
        }
        for (UIView *subview in self.menuView.subviews) {
            [subview resetFrameToFitRTL];
        }
    }
}

#pragma mark - Views
- (void)setupViews {
    _toolView = [[UIView alloc] init];
    _toolView.backgroundColor = TIMCommonDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
    //    [self addSubview:_toolView];

    _menuView = [[UIView alloc] init];
    _menuView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    [_menuView.layer addSublayer:self.separtorLayer];
    [self addSubview:_menuView];

    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:TIMCommonLocalizableString(Cancel) forState:UIControlStateNormal];
    [_cancelButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton sizeToFit];
    [_toolView addSubview:_cancelButton];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"";
    _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
    [_toolView addSubview:_titleLabel];

    _relayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_relayButton setImage:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_mutilselect_forward")] forState:UIControlStateNormal];
    [_relayButton addTarget:self action:@selector(onRelay:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_relayButton];

    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageNamed:TUIChatImagePath_Minimalist(@"icon_mutilselect_delete")] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_deleteButton];

    _selectedCountLabel = [[UILabel alloc] init];
    _selectedCountLabel.text = @"1 Selecte";
    _selectedCountLabel.font = [UIFont systemFontOfSize:14.0];
    [_menuView addSubview:_selectedCountLabel];

    _bottomCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_bottomCancelButton setTitle:TIMCommonLocalizableString(Cancel) forState:UIControlStateNormal];
    _bottomCancelButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_bottomCancelButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [_bottomCancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_bottomCancelButton];
}

#pragma mark - Action
- (void)onCancel:(UIButton *)cancelButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageMultiChooseViewOnCancelClicked:)]) {
        [self.delegate messageMultiChooseViewOnCancelClicked:self];
    }
}

- (void)onRelay:(UIButton *)cancelButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageMultiChooseViewOnRelayClicked:)]) {
        [self.delegate messageMultiChooseViewOnRelayClicked:self];
    }
}

- (void)onDelete:(UIButton *)cancelButton {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageMultiChooseViewOnDeleteClicked:)]) {
        [self.delegate messageMultiChooseViewOnDeleteClicked:self];
    }
}

- (CALayer *)separtorLayer {
    if (_separtorLayer == nil) {
        _separtorLayer = [CALayer layer];

        _separtorLayer.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB").CGColor;
    }
    return _separtorLayer;
}

@end
