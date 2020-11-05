//
//  TUILiveTopSegmentView.m
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveTopSegmentView.h"
#import <Masonry/Masonry.h>
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"

@interface TUILiveTopSegmentView ()

@property(nonatomic, strong)UIView *containerView;
@property(nonatomic, strong)UIButton *liveRoomButton;
@property(nonatomic, strong)UIButton *voiceRoomButton;

@property(nonatomic, strong)UIView *selectView;
@property(nonatomic, assign)NSInteger currentSelectIndex;

@end

@implementation TUILiveTopSegmentView{
    BOOL _isViewReady;
}

- (UIButton *)liveRoomButton {
    if (!_liveRoomButton) {
        _liveRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _liveRoomButton.tag = 2000;
        [_liveRoomButton setTitle:NSLocalizedString(@"TabBarItemLiveText", nil) forState:UIControlStateNormal];
        [_liveRoomButton setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
    }
    return _liveRoomButton;
}

-(UIButton *)voiceRoomButton {
    if (!_voiceRoomButton) {
        _voiceRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceRoomButton.tag = 2001;
        [_voiceRoomButton setTitle:NSLocalizedString(@"LiveAudioChatRoom", nil) forState:UIControlStateNormal];
        [_voiceRoomButton setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
    }
    return _voiceRoomButton;
}

- (UIView *)selectView {
    if (!_selectView) {
        _selectView = [[UIView alloc] init];
    }
    return _selectView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (void)setSelectIndex:(NSInteger)index {
    if (index == 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.selectView.transform = CGAffineTransformIdentity;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.selectView.transform = CGAffineTransformMakeTranslation(self.frame.size.width / 2, 0);
        }];
    }
    self.currentSelectIndex = index;
}

- (NSInteger)currentIndex {
    return self.currentSelectIndex;
}

#pragma mark - 视图生命周期
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    [self bindInteraction];
    [self configUI];
    _isViewReady = YES;
}

- (void)constructViewHierarchy {
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.liveRoomButton];
    [self.containerView addSubview:self.voiceRoomButton];
    [self.containerView addSubview:self.selectView];
}

- (void)layoutUI {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(64);
    }];
    [self.liveRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView);
        make.top.equalTo(self.containerView).offset(20);
        make.bottom.equalTo(self.containerView).offset(-2);
        make.width.equalTo(self.containerView).multipliedBy(0.5);
    }];
    [self.voiceRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView);
        make.top.equalTo(self.containerView).offset(20);
        make.bottom.equalTo(self.containerView).offset(-5);
        make.width.equalTo(self.containerView).multipliedBy(0.5);
    }];
    [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView);
        make.bottom.equalTo(self.containerView);
        make.width.equalTo(self.containerView).multipliedBy(0.5);
        make.height.mas_equalTo(2);
    }];
}

- (void)bindInteraction{
    [self.liveRoomButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceRoomButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
}

// 配置UI样式
- (void)configUI {
    self.selectView.backgroundColor = self.tintColor;
}

#pragma mark - Interaction
- (void)selectAction:(UIButton *)sender {
    NSInteger index = sender.tag - 2000;
    [self setSelectIndex:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(topSegmentView:didClickIndex:)]) {
        [self.delegate topSegmentView:self didClickIndex:self.currentIndex];
    }
}
@end
