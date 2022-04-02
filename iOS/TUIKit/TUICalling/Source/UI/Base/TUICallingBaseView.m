//
//  TUICallingBaseView.m
//  TUICalling
//
//  Created by noah on 2021/9/3.
//

#import "TUICallingBaseView.h"
#import "UIWindow+TUICalling.h"

@interface TUICallingBaseView () <TUICallingFloatingWindowManagerDelegate>

@property (nonatomic, strong) UIWindow *floatingWindow;

@end

@implementation TUICallingBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor t_colorWithHexString:@"#F4F5F9"];
        [[TUICallingFloatingWindowManager shareInstance] setFloatingWindowManagerDelegate:self];
        [self setupCallingBaseViewUI];
    }
    return self;
}

- (void)setupCallingBaseViewUI {
    [self addSubview:self.floatingWindowBtn];
    [self.floatingWindowBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 3);
        make.left.equalTo(self).offset(10);
        make.width.height.equalTo(@(32));
    }];
}

- (void)showCalingViewEnableFloatWindow:(BOOL)enable {
    self.disableCustomView = YES;
    self.floatingWindowBtn.hidden = !enable;
    self.floatingWindow.hidden = NO;
    [self.floatingWindow addSubview:self];
    [self.floatingWindow t_makeKeyAndVisible];
}

- (void)disMissCalingView {
    if (self.disableCustomView) {
        [self removeFromSuperview];
        self.floatingWindow.hidden = YES;
        self.floatingWindow = nil;
    }
    
    if ([TUICallingFloatingWindowManager shareInstance].isFloating) {
        [[TUICallingFloatingWindowManager shareInstance] closeWindowCompletion:nil];
    }
}

- (void)configViewWithUserList:(NSArray<CallUserModel *> *)userList sponsor:(CallUserModel *)sponsor {
}

- (void)enterUser:(CallUserModel *)user {
    NSCAssert(NO, @"%s must be overridden by subclasses", __func__);
}

- (void)leaveUser:(CallUserModel *)user {
}

- (void)updateUser:(CallUserModel *)user animated:(BOOL)animated {
    NSCAssert(NO, @"%s must be overridden by subclasses", __func__);
}

- (void)updateUserVolume:(CallUserModel *)user {
}

- (CallUserModel *)getUserById:(NSString *)userId {
    return nil;
}

- (void)switchToAudio {
}

- (void)acceptCalling {
    NSCAssert(NO, @"%s must be overridden by subclasses", __func__);
}

- (void)refuseCalling {
}

- (void)setCallingTimeStr:(NSString *)timeStr {
    NSCAssert(NO, @"%s must be overridden by subclasses", __func__);
}

#pragma mark -  悬浮小窗口实现

- (void)showMicroFloatingWindow:(TUICallingState)callingState {
    [self showMicroFloatingWindowWithVideoRenderView:nil callingState:callingState completion:nil];
}

- (void)showMicroFloatingWindowWithVideoRenderView:(TUICallingVideoRenderView *)renderView callingState:(TUICallingState)callingState completion:(void (^ __nullable)(BOOL finished))completion {
    [[TUICallingFloatingWindowManager shareInstance] showMicroFloatingWindowWithCallingWindow:self.floatingWindow VideoRenderView:renderView Completion:completion];
    
    if (!self.isVideo || !renderView) {
        [[TUICallingFloatingWindowManager shareInstance] updateMicroWindowText:@"" callingState:callingState];;
    }
}

#pragma mark - Event Action

- (void)floatingWindowTouchEvent:(UIButton *)sender {
    NSCAssert(NO, @"%s must be overridden by subclasses", __func__);
}

#pragma mark - TUICallingFloatingWindowDelegate

- (void)floatingWindowDidClickView {
}

- (void)closeFloatingWindow {
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(hangupCalling)]) {
        [self.actionDelegate hangupCalling];
    }}

#pragma mark - Getter and setter

- (UIWindow *)floatingWindow {
    if (!_floatingWindow) {
        _floatingWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _floatingWindow.windowLevel = UIWindowLevelAlert - 1;
        _floatingWindow.backgroundColor = [UIColor clearColor];
    }
    return _floatingWindow;
}

- (UIButton *)floatingWindowBtn {
    if (!_floatingWindowBtn) {
        _floatingWindowBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_floatingWindowBtn setBackgroundImage:[TUICommonUtil getBundleImageWithName:@"ic_min_window_white"] forState:UIControlStateNormal];
        [_floatingWindowBtn addTarget:self action:@selector(floatingWindowTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
        _floatingWindowBtn.hidden = YES;
    }
    return _floatingWindowBtn;
}

@end
