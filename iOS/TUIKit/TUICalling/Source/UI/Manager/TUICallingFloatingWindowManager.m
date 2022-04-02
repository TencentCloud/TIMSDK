//
//  TUICallingFloatingWindowManager.m
//  TUICalling
//
//  Created by noah on 2022/1/13.
//

#import "TUICallingFloatingWindowManager.h"
#import "TUICallingFloatingWindow.h"
#import "TUICallingVideoRenderView.h"
#import "TUICommonUtil.h"
#import "CallingLocalized.h"
#import "UIWindow+TUICalling.h"

@interface TUICallingFloatingWindowManager() <TUICallingFloatingWindowDelegate>

@property (nonatomic, weak) id<TUICallingFloatingWindowManagerDelegate>delegate;

/// 原calling视图
@property (nonatomic, strong) UIWindow *sourceCallingWindow;

/// 小悬浮框视图
@property (nonatomic, strong) TUICallingFloatingWindow *floatWindow;

/// 小悬浮框视图Frame
@property (nonatomic, assign) CGRect currentFloatWindowFrame;

@end

@implementation TUICallingFloatingWindowManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TUICallingFloatingWindowManager *t_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        t_sharedInstance = [[TUICallingFloatingWindowManager alloc] init];
    });
    return t_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFloating = NO;
        self.currentFloatWindowFrame = CGRectZero;
    }
    return self;
}

- (void)setFloatingWindowManagerDelegate:(id<TUICallingFloatingWindowManagerDelegate>)delegagte {
    self.delegate = delegagte;
}

- (void)showMicroFloatingWindowWithCallingWindow:(UIWindow *)callingWindow VideoRenderView:(TUICallingVideoRenderView *)renderView Completion:(void (^ __nullable)(BOOL finished))completion {
    if (self.isFloating) return;
    if (!callingWindow) return;
    self.sourceCallingWindow = callingWindow;
    self.isFloating = YES;
    
    [UIView animateWithDuration:0.4 animations:^{
        callingWindow.transform = CGAffineTransformMakeScale(0.2, 0.2);
        if (renderView) {
            callingWindow.frame = [self getFloatingWindowFrame:TUICallingFloatingWindowTypeVideo];
        } else {
            callingWindow.frame = [self getFloatingWindowFrame:TUICallingFloatingWindowTypeAudio];
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        callingWindow.hidden = YES;
        
        if (renderView) {
            self.floatWindow.frame = [self getFloatingWindowFrame:TUICallingFloatingWindowTypeVideo];
            [self.floatWindow updateMicroWindowWithRenderView:renderView];
        } else {
            self.floatWindow.frame = [self getFloatingWindowFrame:TUICallingFloatingWindowTypeAudio];
        }
        
        [self.floatWindow t_makeKeyAndVisible];
        [self.floatWindow layoutIfNeeded];
        [self.floatWindow floatingWindowRoundedRect];
    }];
}

- (void)hiddenMicroFloatingWindow{
    self.sourceCallingWindow.hidden = NO;
    self.floatWindow.hidden = YES;
    self.floatWindow = nil;
    [UIView animateWithDuration:0.6 animations:^{
        self.sourceCallingWindow.transform = CGAffineTransformIdentity;
        self.sourceCallingWindow.frame = [UIScreen mainScreen].bounds;
    } completion:^(BOOL finished) {
        self.isFloating = NO;
    }];
}

- (void)closeWindowCompletion:(void (^ __nullable)(BOOL finished))completion {
    if (!self.isFloating) return;
    self.floatWindow.hidden = YES;
    self.floatWindow = nil;
    self.isFloating = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeFloatingWindow)]) {
        [self.delegate closeFloatingWindow];
    }
}

- (void)switchToAudioMicroWindowWith:(TUICallingState)callingState {
    if (!self.isFloating) return;
    
    [self updateMicroWindowText:@"" callingState:callingState];
    [UIView animateWithDuration:0.2 animations:^{
        self.floatWindow.frame = [self getFloatingWindowFrame:TUICallingFloatingWindowTypeAudio];
    } completion:^(BOOL finished) {
        [self.floatWindow layoutIfNeeded];
        [self.floatWindow floatingWindowRoundedRect];
    }];
}

- (void)updateMicroWindowText:(NSString *)textStr callingState:(TUICallingState)callingState {
    if (!self.isFloating) return;
    NSString *desStr;
    
    if (textStr && textStr.length > 0) {
        desStr = textStr;
    } else {
        desStr = [self callingStateStrWith:callingState];
    }
    
    [self.floatWindow updateMicroWindowWithText:desStr];
}

- (void)updateMicroWindowRenderView:(TUICallingVideoRenderView *)renderView {
    if (!self.isFloating || !renderView) return;
    
    self.floatWindow.frame = [self getFloatingWindowFrame:TUICallingFloatingWindowTypeVideo];
    [self.floatWindow updateMicroWindowWithRenderView:renderView];
}

- (NSString *)callingStateStrWith:(TUICallingState)callingState {
    NSString *callingStateStr;
    switch (callingState) {
        case TUICallingStateDailing:
            callingStateStr = CallingLocalize(@"Demo.TRTC.Calling.FloatingWindow.dailing");
            break;
        case TUICallingStateOnInvitee:
            callingStateStr = CallingLocalize(@"Demo.TRTC.Calling.FloatingWindow.waitaccept");
            break;
        case TUICallingStateCalling:
            callingStateStr = @"";
            break;
        default:
            break;
    }
    return callingStateStr;
}

#pragma mark - TUICallingFloatingWindowDelegate

- (void)floatingWindowDidClickView {
    [self hiddenMicroFloatingWindow];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(floatingWindowDidClickView)]) {
        [self.delegate floatingWindowDidClickView];
    }
}

- (void)floatingWindowChangedFrame {
    self.currentFloatWindowFrame = self.floatWindow.frame;
    self.sourceCallingWindow.frame = self.currentFloatWindowFrame;
}

#pragma mark - Private

- (CGRect)getFloatingWindowFrame:(TUICallingFloatingWindowType)floatingWindowType{
    CGRect targetFrame = kMicroAudioViewRect;
    
    if (floatingWindowType == TUICallingFloatingWindowTypeVideo) {
        targetFrame = kMicroVideoViewRect;
    }
    
    CGPoint currentFloatWindowPoint = self.currentFloatWindowFrame.origin;
    CGSize currentFloatWindowSize = self.currentFloatWindowFrame.size;
    
    if (currentFloatWindowPoint.x || currentFloatWindowPoint.y) {
        CGFloat targetFrameX = targetFrame.origin.x;
        CGFloat targetFrameY = targetFrame.origin.y;
        CGFloat targetFrameWidth = targetFrame.size.width;
        CGFloat targetFrameHeight = targetFrame.size.height;
        
        if (currentFloatWindowPoint.x > Screen_Width / 2.0) {
            // 在右边
            targetFrameX = Screen_Width - targetFrameWidth;
        } else {
            // 在左边
            targetFrameX = 0;
        }
        
        targetFrameY = currentFloatWindowPoint.y + (currentFloatWindowSize.height - targetFrameHeight) / 2.0;
        
        // 修正Y坐标
        if (targetFrameY <= StatusBar_Height) {
            targetFrameY = StatusBar_Height;
        }
        
        if ((targetFrameY + targetFrameHeight) >= (Screen_Height - Bottom_SafeHeight)) {
            targetFrameY = Screen_Height - targetFrameHeight - Bottom_SafeHeight;
        }
        
        targetFrame = CGRectMake(targetFrameX, targetFrameY, targetFrameWidth, targetFrameHeight);
    }
    
    return targetFrame;
}

#pragma mark - Getter And Setter

- (TUICallingFloatingWindow *)floatWindow {
    if (!_floatWindow) {
        _floatWindow = [[TUICallingFloatingWindow alloc] initWithFrame:CGRectZero delegate:self];
        _floatWindow.windowLevel = UIWindowLevelAlert - 1;
        _floatWindow.backgroundColor = [UIColor clearColor];
    }
    return _floatWindow;
}

@end
