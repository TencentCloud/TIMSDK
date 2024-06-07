//
//  TUICallingSingleView.m
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingSingleView.h"
#import "TUICallingVideoRenderView.h"
#import "TUICallingFloatingWindowManager.h"
#import "TUILogin.h"
#import "TUIDefine.h"
#import "TUICallEngineHeader.h"
#import "TUICallingUserModel.h"

static CGFloat const kCallingSingleSmallVideoViewWidth = 100.0f;

#define kTUICallingSingleViewMicroRenderFrame CGRectMake(isRTL() ? 18 : (self.frame.size.width - kCallingSingleSmallVideoViewWidth - 18),\
StatusBar_Height + 40, kCallingSingleSmallVideoViewWidth, kCallingSingleSmallVideoViewWidth / 9.0 * 16.0)

@interface TUICallingSingleView () <TUICallingVideoRenderViewDelegate>

@property (nonatomic, strong) TUICallingVideoRenderView *localPreView;
@property (nonatomic, strong) TUICallingVideoRenderView *remotePreView;
@property (nonatomic, assign) BOOL isLocalPreViewLarge;
@property (nonatomic, strong) CallingUserModel *remoteUser;

@end

@implementation TUICallingSingleView

- (instancetype)initWithFrame:(CGRect)frame
                 localPreView:(TUICallingVideoRenderView *)localPreView
                remotePreView:(TUICallingVideoRenderView *)remotePreView {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.localPreView = localPreView;
        self.remotePreView = remotePreView;
        self.localPreView.delegate = self;
        self.remotePreView.delegate = self;
        self.isLocalPreViewLarge = YES;
        [self setupCallingSingleView];
    }
    return self;
}

- (void)setupCallingSingleView {
    self.localPreView.frame = self.bounds;
    [self.localPreView setUserInteractionEnabled:NO];
    self.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
    [self addSubview:self.remotePreView];
    [self addSubview:self.localPreView];
    [TUICallingAction openCamera:TUICameraFront videoView:self.localPreView];
}

#pragma mark - BaseCallViewProtocol

- (void)updateViewWithUserList:(NSArray<CallingUserModel *> *)userList
                       sponsor:(CallingUserModel *)sponsor
                      callType:(TUICallMediaType)callType
                      callRole:(TUICallRole)callRole {
    if (callRole == TUICallRoleCall) {
        for (CallingUserModel *userModel in userList) {
            if (!(userModel.userId && [userModel.userId isEqualToString:[TUILogin getUserID]])) {
                self.remoteUser = userModel;
                break;
            }
        }
        return;
    }
    
    self.remoteUser = sponsor;
}

- (void)updateUserInfo:(CallingUserModel *)userModel {
    if ([self.remoteUser.userId isEqualToString:userModel.userId]) {
        [self.remotePreView configViewWithUserModel:userModel];
    }
}

- (void)updateRemoteView {
    if (![self.remoteUser.userId isEqualToString:[TUILogin getUserID]]) {
        [self.remotePreView configViewWithUserModel:self.remoteUser];
        [TUICallingAction startRemoteView:self.remoteUser.userId videoView:self.remotePreView onPlaying:^(NSString * _Nonnull userId) {
        } onLoading:^(NSString * _Nonnull userId) {
        } onError:^(NSString * _Nonnull userId, int code, NSString * _Nonnull errMsg) {
        }];
        [self switchTo2UserPreView];
    }
}

- (void)setRemotePreViewWith:(CallingUserModel *)userModel{
    if (![userModel.userId isEqualToString:[TUILogin getUserID]]) {
        [self.remotePreView configViewWithUserModel:userModel];
        [TUICallingAction startRemoteView:self.remoteUser.userId videoView:self.remotePreView onPlaying:^(NSString * _Nonnull userId) {
        } onLoading:^(NSString * _Nonnull userId) {
        } onError:^(NSString * _Nonnull userId, int code, NSString * _Nonnull errMsg) {
        }];
    }
}

- (void)updateCallingSingleView {
    if (self.isLocalPreViewLarge) {
        self.remotePreView.userInteractionEnabled = YES;
        self.remotePreView.frame = kTUICallingSingleViewMicroRenderFrame;
        self.localPreView.frame = [UIScreen mainScreen].bounds;
        [self.localPreView removeFromSuperview];
        [self.remotePreView removeFromSuperview];
        [self insertSubview:self.localPreView atIndex:0];
        [self insertSubview:self.remotePreView aboveSubview:self.localPreView];
    } else {
        self.localPreView.userInteractionEnabled = YES;
        self.remotePreView.frame = [UIScreen mainScreen].bounds;
        self.localPreView.frame = kTUICallingSingleViewMicroRenderFrame ;
        [self.remotePreView removeFromSuperview];
        [self.localPreView removeFromSuperview];
        [self insertSubview:self.remotePreView atIndex:0];
        [self insertSubview:self.localPreView aboveSubview:self.remotePreView];
    }
}

#pragma mark - TUICallingVideoRenderViewDelegate

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.view.frame.size.width == kCallingSingleSmallVideoViewWidth) {
        [self switchPreView];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    if (!(panGesture.view && panGesture.view.superview && [panGesture.view.superview isKindOfClass:[TUICallingVideoRenderView class]])) {
        return;
    }
    
    UIView *smallView = panGesture.view.superview;
    
    if (smallView.frame.size.width != kCallingSingleSmallVideoViewWidth) {
        return;
    }
    
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self];
        CGFloat newCenterX = translation.x + (smallView.center.x);
        CGFloat newCenterY = translation.y + (smallView.center.y);
        
        if ((newCenterX < (smallView.bounds.size.width / 2.0)) || (newCenterX > self.bounds.size.width - (smallView.bounds.size.width) / 2.0)) {
            return;
        }
        
        if ((newCenterY < (smallView.bounds.size.height) / 2.0) ||
            (newCenterY > self.bounds.size.height - (smallView.bounds.size.height) / 2.0))  {
            return;
        }
        
        [UIView animateWithDuration:0.1 animations:^{
            smallView.center = CGPointMake(newCenterX, newCenterY);
        }];
        [panGesture setTranslation:CGPointZero inView:self];
    }
}

#pragma mark - Private

- (void)switchTo2UserPreView {
    if (!self.remotePreView || self.isLocalPreViewLarge == NO) {
        return;
    }
    
    [self.localPreView setUserInteractionEnabled:YES];
    [[self.localPreView.subviews firstObject] setUserInteractionEnabled: NO];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.localPreView.frame = kTUICallingSingleViewMicroRenderFrame;
        self.remotePreView.frame = self.frame;
    } completion:^(BOOL finished) {
        [self.remotePreView removeFromSuperview];
        [self insertSubview:self.remotePreView belowSubview:self.localPreView];
        self.isLocalPreViewLarge = NO;
        [[TUICallingFloatingWindowManager shareInstance] setRenderView:self.remotePreView];
    }];
}

- (void)switchPreView {
    if (!self.remotePreView) {
        return;
    }
    
    TUICallingVideoRenderView *remoteView = self.remotePreView;
    
    if (self.isLocalPreViewLarge) {
        remoteView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            remoteView.frame = self.frame;
            self.localPreView.frame = kTUICallingSingleViewMicroRenderFrame;
        } completion:^(BOOL finished) {
            [remoteView removeFromSuperview];
            [self insertSubview:remoteView belowSubview:self.localPreView];
            
            if (self.localPreView.isHidden || remoteView.isHidden) {
                [self.localPreView setUserInteractionEnabled:NO];
                [remoteView setUserInteractionEnabled:NO];
            } else {
                [self.localPreView setUserInteractionEnabled:YES];
            }
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.localPreView.frame = self.frame;
            remoteView.frame = kTUICallingSingleViewMicroRenderFrame;
        } completion:^(BOOL finished) {
            [self.localPreView removeFromSuperview];
            [self insertSubview:self.localPreView belowSubview:remoteView];
            
            if (self.localPreView.isHidden || remoteView.isHidden) {
                [self.localPreView setUserInteractionEnabled:NO];
                [remoteView setUserInteractionEnabled:NO];
            } else {
                [remoteView setUserInteractionEnabled:YES];
            }
        }];
    }
    
    self.isLocalPreViewLarge = !_isLocalPreViewLarge;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
