//
//  TUICallingVideoRenderView.m
//  TUICalling
//
//  Created by noah on 2021/8/24.
//

#import "TUICallingVideoRenderView.h"
#import "TRTCCallingModel.h"
#import "UIColor+TUIHex.h"
#import <Masonry/Masonry.h>

@interface TUICallingVideoRenderView()

/// 记录用户数据
@property (nonatomic, strong) CallUserModel *userModel;

/// 页面是否准备完成
@property (nonatomic, assign) BOOL isViewReady;

/// 通话音量视图
@property (nonatomic, strong) UIProgressView *volumeProgress;

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
    [self addSubview:self.volumeProgress];
    [self.volumeProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.equalTo(@(4));
    }];
}

- (void)configViewWithUserModel:(CallUserModel *)userModel {
    self.backgroundColor = [UIColor t_colorWithHexString:@"#55534F"];
    BOOL noModel = userModel.userId.length == 0;
    
    if (!noModel) {
        self.volumeProgress.progress = userModel.volume;
    }
    
    self.volumeProgress.hidden = noModel;
}

- (UIProgressView *)volumeProgress {
    if (!_volumeProgress) {
        _volumeProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _volumeProgress.backgroundColor = [UIColor clearColor];
    }
    return _volumeProgress;
}

@end
