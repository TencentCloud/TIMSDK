//
//  TUIConversationMultiChooseView_Minimalist.m
//  Pods
//
//  Created by harvy on 2020/11/27.
//

#import "TUIConversationMultiChooseView_Minimalist.h"
#import "TUIGlobalization.h"
#import "TUIDarkModel.h"
#import "TUIThemeManager.h"
#import "UIView+TUILayout.h"

@interface TUIConversationMultiChooseView_Minimalist ()

@property (nonatomic, strong) CALayer *separtorLayer;

@end

@implementation TUIConversationMultiChooseView_Minimalist

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
    CGFloat menuHeight = 54 + 3;
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
//    self.separtorLayer.frame = CGRectMake(0, 0, self.menuView.mm_w, 1);
    
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
    _toolView.backgroundColor = TUICoreDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
    [self addSubview:_toolView];
    
    _menuView = [[UIView alloc] init];
    _menuView.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#FFFFFF");
    [_menuView.layer addSublayer:self.separtorLayer];
    [self addSubview:_menuView];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setTitle:TUIKitLocalizableString(Cancel) forState:UIControlStateNormal];
    [_cancelButton setTitleColor:TUICoreDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
//    [_cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton sizeToFit];
    [_toolView addSubview:_cancelButton];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"";
    _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _titleLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
    [_toolView addSubview:_titleLabel];
    
    _hideButton = [TUIBlockButton buttonWithType:UIButtonTypeCustom];
    [_hideButton setTitle:@"Mark as Hide" forState:UIControlStateNormal];
    _hideButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    TUICoreDynamicColor(@"common_switch_on_color", @"#147AFF");
    [_hideButton setTitleColor:TUICoreDynamicColor(@"primary_theme_color", @"#147AFF") forState:UIControlStateNormal];
    [_hideButton setTitleColor:[TUICoreDynamicColor(@"primary_theme_color", @"#147AFF") colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
//    [_hideButton addTarget:self action:@selector(onMarkHideAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_hideButton];
    
    _readButton = [TUIBlockButton buttonWithType:UIButtonTypeCustom];
    [_readButton setTitle:@"Mark as Read" forState:UIControlStateNormal];
    _readButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_readButton setTitleColor:TUICoreDynamicColor(@"primary_theme_color", @"#147AFF") forState:UIControlStateNormal];
    [_readButton setTitleColor:[TUICoreDynamicColor(@"primary_theme_color", @"#147AFF") colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
//    [_readButton addTarget:self action:@selector(onMarkReadAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_readButton];
    
    _deleteButton = [TUIBlockButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setTitle:TUIKitLocalizableString(Delete) forState:UIControlStateNormal];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_deleteButton setTitleColor:TUICoreDynamicColor(@"primary_theme_color", @"#147AFF") forState:UIControlStateNormal];
    [_deleteButton setTitleColor:[TUICoreDynamicColor(@"primary_theme_color", @"#147AFF") colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
//    [_deleteButton addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
    [_menuView addSubview:_deleteButton];
}

#pragma mark - Action

- (CALayer *)separtorLayer
{
    if (_separtorLayer == nil) {
        _separtorLayer = [CALayer layer];
        
        _separtorLayer.backgroundColor = TUICoreDynamicColor(@"separator_color", @"#DBDBDB").CGColor;
    }
    return _separtorLayer;
}

@end
