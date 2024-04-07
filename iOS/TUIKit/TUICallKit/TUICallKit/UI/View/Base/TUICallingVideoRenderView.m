//
//  TUICallingVideoRenderView.m
//  TUICalling
//
//  Created by noah on 2021/8/24.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallingVideoRenderView.h"
#import "TUICallEngineHeader.h"
#import "UIColor+TUICallingHex.h"
#import "Masonry.h"
#import "TUICallingUserModel.h"
#import "TUICallingUserManager.h"
#import "TUICallingCommon.h"
#import "UIImageView+WebCache.h"

@interface TUICallingVideoRenderView()

@property (nonatomic, strong) CallingUserModel *userModel;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *userIconImageView;
@property (nonatomic, assign) BOOL isViewReady;

@end

@implementation TUICallingVideoRenderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isViewReady = NO;
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self.isViewReady) return;
    self.isViewReady = YES;
    
    UIView *gestureView = [[UIView alloc] init];
    gestureView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [gestureView addGestureRecognizer:tap];
    [pan requireGestureRecognizerToFail:tap];
    [gestureView addGestureRecognizer:pan];
    
    [self addSubview:self.maskView];
    [self addSubview:self.userIconImageView];
    [self addSubview:gestureView];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.userIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.height.equalTo(self.mas_width).multipliedBy(1 / 4.0);
    }];
    [gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)configViewWithUserModel:(CallingUserModel *)userModel {
    self.backgroundColor = [UIColor t_colorWithHexString:@"#55534F"];
    
    self.maskView.hidden = userModel.isVideoAvailable;
    self.userIconImageView.hidden = userModel.isVideoAvailable;
    
    if (userModel.isVideoAvailable) {
        return;
    }
    
    if ([userModel.userId isEqualToString:[TUICallingUserManager getSelfUserId]]) {
        self.maskView.backgroundColor = [UIColor t_colorWithHexString:@"#333333"];
    } else {
        self.maskView.backgroundColor = [UIColor t_colorWithHexString:@"#444444"];
    }
    
    [self.userIconImageView sd_setImageWithURL:[NSURL URLWithString:userModel.avatar]
                              placeholderImage:[TUICallingCommon getBundleImageWithName:@"userIcon"]];
    
}

#pragma mark - Gesture Action

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapGestureAction:)]) {
        [self.delegate tapGestureAction:tapGesture];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)panGesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(panGestureAction:)]) {
        [self.delegate panGestureAction:panGesture];
    }
}

#pragma mark - Setter and Getter

-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.userInteractionEnabled = true;
        _maskView.backgroundColor = [UIColor t_colorWithHexString:@"#55534F"];
        _maskView.hidden = YES;
    }
    return _maskView;
}

- (UIImageView *)userIconImageView {
    if (!_userIconImageView) {
        _userIconImageView = [[UIImageView alloc] initWithFrame: CGRectZero];
        _userIconImageView.layer.masksToBounds = YES;
        _userIconImageView.layer.cornerRadius = 5.0;
        _userIconImageView.hidden = YES;
    }
    return _userIconImageView;
}

@end
