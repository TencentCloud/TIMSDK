//
//  TUICallingFloatingWindowManager.m
//  TUICalling
//
//  Created by noah on 2022/1/13.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingFloatingWindowManager.h"
#import "TUICallingVideoRenderView.h"
#import "TUICallingCommon.h"
#import "CallingLocalized.h"
#import "UIWindow+TUICalling.h"
#import "TUIDefine.h"
#import "TUICallingUserModel.h"
#import "TUICallingStatusManager.h"

@interface TUICallingFloatingWindowManager() <TUICallingFloatingWindowDelegate>

@property (nonatomic, weak) id<TUICallingFloatingWindowManagerDelegate>delegate;
@property (nonatomic, strong) UIWindow *sourceCallingWindow;
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(callMediaTypeChanged)
                                                     name:EventSubCallMediaTypeChanged object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFloatingWindowManagerDelegate:(id<TUICallingFloatingWindowManagerDelegate>)delegate {
    self.delegate = delegate;
}

- (void)showMicroFloatingWindow:(void (^ __nullable)(BOOL finished))completion {
    if (self.isFloating) {
        return;
    }
    self.sourceCallingWindow = [TUICallingCommon getKeyWindow];
    self.isFloating = YES;
    dispatch_callkit_main_async_safe(^{
        [UIView animateWithDuration:0.4 animations:^{
            self.sourceCallingWindow.transform = CGAffineTransformMakeScale(0.2, 0.2);
            self.sourceCallingWindow.frame = [self getFloatingWindowFrame];
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
            self.floatWindow.frame = [self getFloatingWindowFrame];
            [self.floatWindow t_makeKeyAndVisible];
            [self.floatWindow layoutIfNeeded];
            [self.floatWindow floatingWindowRoundedRect];
            self.sourceCallingWindow.hidden = YES;
            [self updateDescribeText:@""];
        }];
    });
}

- (void)closeMicroFloatingWindow:(void (^ __nullable)(BOOL finished))completion {
    if (!self.isFloating) {
        return;
    }
    dispatch_callkit_main_async_safe(^{
        self.floatWindow.hidden = YES;
        self.floatWindow = nil;
        self.renderView = nil;
        self.isFloating = NO;
    });
}

- (void)updateDescribeText:(NSString *)textStr {
    if (!self.isFloating) {
        return;
    }
    NSString *describeText = [self getCallKitStatusStr];
    if (textStr && textStr.length > 0) {
        describeText = textStr;
    }
    dispatch_callkit_main_async_safe(^{
        [self.floatWindow updateMicroWindowWithText:describeText];
    });
}

- (void)updateUserModel:(CallingUserModel *)userModel {
    if (!self.isFloating) {
        return;
    }
    dispatch_callkit_main_async_safe(^{
        if (!userModel.isVideoAvailable && ([TUICallingStatusManager shareInstance].callMediaType == TUICallMediaTypeVideo)) {
            [self.floatWindow updateMicroWindowBackgroundAvatar:userModel.avatar];
        } else {
            [self.floatWindow updateMicroWindowBackgroundAvatar:@""];
        }
    });
}

#pragma mark - NSNotificationCenter

- (void)callMediaTypeChanged {
    if (!self.isFloating || ([TUICallingStatusManager shareInstance].callStatus == TUICallStatusNone)) {
        return;
    }
    dispatch_callkit_main_async_safe(^{
        [UIView animateWithDuration:0.2 animations:^{
            TUICallMediaType callType = [TUICallingStatusManager shareInstance].callMediaType;
            self.floatWindow.frame = [self getFloatingWindowFrame:callType];
            if (callType == TUICallMediaTypeVideo) {
                self.renderView.hidden = NO;
            } else {
                [self.floatWindow updateMicroWindowWithRenderView:nil];
            }
        } completion:^(BOOL finished) {
            [self updateDescribeText:@""];
            [self.floatWindow updateMicroWindowBackgroundAvatar:@""];
            [self.floatWindow layoutIfNeeded];
            [self.floatWindow floatingWindowRoundedRect];
        }];
    });
}

#pragma mark - TUICallingFloatingWindowDelegate

- (void)floatingWindowDidClickView {
    [self hiddenMicroFloatingWindow];
    if (self.delegate && [self.delegate respondsToSelector:@selector(floatingWindowDidClickView)]) {
        dispatch_callkit_main_async_safe(^{
            [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
            [self.delegate floatingWindowDidClickView];
        });
    }
}

- (void)hiddenMicroFloatingWindow {
    dispatch_callkit_main_async_safe(^{
        self.sourceCallingWindow.hidden = NO;
        self.floatWindow.hidden = YES;
        self.floatWindow = nil;
        [UIView animateWithDuration:0.6 animations:^{
            self.sourceCallingWindow.transform = CGAffineTransformIdentity;
            self.sourceCallingWindow.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
            self.isFloating = NO;
        }];
    });
}

- (void)floatingWindowChangedFrame {
    dispatch_callkit_main_async_safe(^{
        self.currentFloatWindowFrame = self.floatWindow.frame;
        self.sourceCallingWindow.frame = self.currentFloatWindowFrame;
    });
}

#pragma mark - Private

- (NSString *)getCallKitStatusStr {
    TUICallStatus callStatus = [TUICallingStatusManager shareInstance].callStatus;
    NSString *callKitStatusStr = @"";
    switch ([TUICallingStatusManager shareInstance].callRole) {
        case TUICallRoleCall: {
            if (callStatus == TUICallStatusWaiting) {
                callKitStatusStr = TUICallingLocalize(@"Demo.TRTC.Calling.FloatingWindow.dailing");
            }
        } break;
        case TUICallRoleCalled: {
            if (callStatus == TUICallStatusWaiting) {
                callKitStatusStr = TUICallingLocalize(@"Demo.TRTC.Calling.FloatingWindow.waitaccept");
            }
        } break;
        case TUICallRoleNone:
        default:
            break;
    }
    return callKitStatusStr;
}

- (CGRect)getFloatingWindowFrame {
    TUICallMediaType callMediaType = [TUICallingStatusManager shareInstance].callMediaType;
    if ([TUICallingStatusManager shareInstance].callScene != TUICallSceneSingle) {
        callMediaType = TUICallMediaTypeAudio;
    }
    return [self getFloatingWindowFrame:callMediaType];
}

- (CGRect)getFloatingWindowFrame:(TUICallMediaType)callMediaType {
    CGRect targetFrame = kMicroAudioViewRect;
    if (callMediaType == TUICallMediaTypeVideo) {
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
            targetFrameX = Screen_Width - targetFrameWidth;
        } else {
            targetFrameX = 0;
        }
        
        targetFrameY = currentFloatWindowPoint.y + (currentFloatWindowSize.height - targetFrameHeight) / 2.0;
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

- (void)setRenderView:(TUICallingVideoRenderView *)renderView {
    if (!self.isFloating || !renderView) {
        return;
    }
    self.floatWindow.frame = [self getFloatingWindowFrame:TUICallMediaTypeVideo];
    [self.floatWindow updateMicroWindowWithRenderView:renderView];
}

- (TUICallingFloatingWindow *)floatWindow {
    if (!_floatWindow) {
        _floatWindow = [[TUICallingFloatingWindow alloc] initWithFrame:CGRectZero delegate:self];
        _floatWindow.windowLevel = UIWindowLevelAlert - 1;
        _floatWindow.backgroundColor = [UIColor clearColor];
    }
    return _floatWindow;
}

@end
