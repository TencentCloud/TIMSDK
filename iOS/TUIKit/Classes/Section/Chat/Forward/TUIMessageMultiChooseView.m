//
//  TUIMessageMultiChooseView.m
//  Pods
//
//  Created by harvy on 2020/11/27.
//

#import "TUIMessageMultiChooseView.h"
#import <MMLayout/UIView+MMLayout.h>
#import "NSBundle+TUIKIT.h"
#import "UIColor+TUIDarkMode.h"

@implementation TUIMessageMultiChooseView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    } else {
        return hitView;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat toolHeight = 44;
    CGFloat menuHeight = 44;
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
    
    // menuView 均布
    {
        NSInteger count = self.menuView.subviews.count;
        CGFloat width = self.menuView.bounds.size.width / count;
        CGFloat height = (self.menuView.bounds.size.height - centerBottomOffset);
        for (int i = 0; i < self.menuView.subviews.count; i++) {
            UIView *sub = self.menuView.subviews[i];
            CGFloat centerY = (self.menuView.bounds.size.height - height) * 0.5;
            sub.frame = CGRectMake(i * width, centerY -= 0.5 * centerBottomOffset, width, height);
        }
    }
}

#pragma mark - Views
- (void)setupViews
{
    _toolView = [[UIView alloc] init];
    _toolView.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor darkGrayColor]];
    [self addSubview:_toolView];
    
    _menuView = [[UIView alloc] init];
    _menuView.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor darkGrayColor]];
    [self addSubview:_menuView];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:TUILocalizableString(Cancel) forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]] forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [_cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton sizeToFit];
    [_toolView addSubview:_cancelButton];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"";
    _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _titleLabel.textColor = [UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    [_toolView addSubview:_titleLabel];
    
    _relayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_relayButton setTitle:TUILocalizableString(Forward) forState:UIControlStateNormal];
    _relayButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_relayButton setTitleColor:[UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_relayButton addTarget:self action:@selector(onRelay:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_relayButton];
    
    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setTitle:TUILocalizableString(Delete) forState:UIControlStateNormal];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_deleteButton setTitleColor:[UIColor d_colorWithColorLight:[UIColor blackColor] dark:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_deleteButton];
}

#pragma mark - Action
- (void)onCancel:(UIButton *)cancelButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageMultiChooseViewOnCancelClicked:)]) {
        [self.delegate messageMultiChooseViewOnCancelClicked:self];
    }
}

- (void)onRelay:(UIButton *)cancelButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageMultiChooseViewOnRelayClicked:)]) {
        [self.delegate messageMultiChooseViewOnRelayClicked:self];
    }
}

- (void)onDelete:(UIButton *)cancelButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageMultiChooseViewOnDeleteClicked:)]) {
        [self.delegate messageMultiChooseViewOnDeleteClicked:self];
    }
}

@end
