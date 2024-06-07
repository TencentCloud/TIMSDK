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

@interface TUICallingVideoRenderView()

@property (nonatomic, strong) CallingUserModel *userModel;
@property (nonatomic, strong) UIProgressView *volumeProgress;
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
    
    [self addSubview:gestureView];
    [self addSubview:self.volumeProgress];
    
    [gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.volumeProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.equalTo(@(4));
    }];
}

- (void)configViewWithUserModel:(CallingUserModel *)userModel {
    self.backgroundColor = [UIColor t_colorWithHexString:@"#55534F"];
    BOOL noModel = userModel.userId.length == 0;
    
    if (!noModel) {
        self.volumeProgress.progress = userModel.volume;
    }
    
    self.volumeProgress.hidden = noModel;
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

- (UIProgressView *)volumeProgress {
    if (!_volumeProgress) {
        _volumeProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _volumeProgress.backgroundColor = [UIColor clearColor];
    }
    return _volumeProgress;
}

@end
