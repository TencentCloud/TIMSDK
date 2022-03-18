//
//  TUICallingBaseView.m
//  TUICalling
//
//  Created by noah on 2021/9/3.
//

#import "TUICallingBaseView.h"

@interface TUICallingBaseView ()

@property (nonatomic, strong) UIWindow *window;

@end

@implementation TUICallingBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor t_colorWithHexString:@"#F4F5F9"];
    }
    return self;
}

- (void)show {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelAlert + 1;
    self.window.backgroundColor = [UIColor clearColor];
    [self.window addSubview:self];
    
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive || windowScene.activationState == UISceneActivationStateBackground) {
                self.window.windowScene = windowScene;
                break;
            }
        }
    }
    
    [self.window makeKeyAndVisible];
}

- (void)disMiss {
    [self removeFromSuperview];
    self.window.hidden = YES;
    self.window = nil;
}

- (void)configViewWithUserList:(NSArray<CallUserModel *> *)userList sponsor:(CallUserModel *)sponsor {
}

- (void)enterUser:(CallUserModel *)user {
}

- (void)leaveUser:(CallUserModel *)user {
}

- (void)updateUser:(CallUserModel *)user animated:(BOOL)animated {
}

- (void)updateUserVolume:(CallUserModel *)user {
}

- (CallUserModel *)getUserById:(NSString *)userId {
    return nil;
}

- (void)switchToAudio {
}

- (void)acceptCalling {
}

- (void)refuseCalling {
}

- (void)setCallingTimeStr:(NSString *)timeStr {
    NSCAssert(NO, @"%s must be overridden by subclasses", __func__);
}

#pragma mark - Getter and setter

- (void)setCurrentUser:(CallUserModel *)currentUser {
    if (currentUser) {
        _currentUser = currentUser;
    }
}

@end
