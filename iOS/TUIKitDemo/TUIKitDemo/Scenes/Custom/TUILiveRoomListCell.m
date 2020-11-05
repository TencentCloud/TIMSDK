//
//  TUILiveRoomListCell.m
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveRoomListCell.h"
#import "THeader.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
// Data Model
#import "TUILiveRoomInfo.h"

@interface TUILiveRoomListCell ()

@property(nonatomic, strong) UIImageView *coverImageView;
@property(nonatomic, strong) UILabel *anchorNameLabel;
@property(nonatomic, strong) UILabel *roomNameLabel;
@property(nonatomic, strong) UILabel *memberCountLabel;

@end

@implementation TUILiveRoomListCell{
    BOOL _isViewReady;
}

#pragma mark - 视图属性懒加载
- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView = imageView;
    }
    return _coverImageView;
}

- (UILabel *)anchorNameLabel {
    if (!_anchorNameLabel) {
        _anchorNameLabel = [[UILabel alloc] init];
        _anchorNameLabel.text = @"";
        _anchorNameLabel.font = [UIFont systemFontOfSize:14.0];
        _anchorNameLabel.textColor = RGB(255, 255, 255);
        _anchorNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _anchorNameLabel;
}

- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        _roomNameLabel.text = @"";
        _roomNameLabel.font = [UIFont systemFontOfSize:14.0];
        _roomNameLabel.textColor = RGB(255, 255, 255);
        _roomNameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _roomNameLabel;
}

- (UILabel *)memberCountLabel {
    if (!_memberCountLabel) {
        _memberCountLabel = [[UILabel alloc] init];
        _memberCountLabel.text = @"";
        _memberCountLabel.font = [UIFont systemFontOfSize:14.0];
        _memberCountLabel.textColor = RGB(255, 255, 255);
        _memberCountLabel.textAlignment = NSTextAlignmentLeft;
        _memberCountLabel.numberOfLines = 0;
    }
    return _memberCountLabel;
}

#pragma mark - 视图数据设置
- (void)setCellWithRoomInfo:(TUILiveRoomInfo *)info {
    NSURL *imageUrl = [NSURL URLWithString:info.coverUrl];
    [self.coverImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"live_room_default_cover"]];
    self.anchorNameLabel.text = info.ownerName;
    self.roomNameLabel.text = info.roomName;
    self.memberCountLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LiveOnlineCountFormat", nil), (long)info.memberCount];
}

#pragma mark - 视图生命周期
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (self->_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    [self configUI];
    self->_isViewReady = YES;
}

// 初始化视图层级
- (void)constructViewHierarchy {
    [self addSubview:self.coverImageView];
    [self addSubview:self.anchorNameLabel];
    [self addSubview:self.roomNameLabel];
    [self addSubview:self.memberCountLabel];
}

// 激活视图约束
- (void)layoutUI {
    // Masnory布局
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self);
    }];
    [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(6.0);
        make.bottom.equalTo(self).offset(-6.0);
        make.width.lessThanOrEqualTo(self).multipliedBy(0.55);
    }];
    [self.anchorNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(6.0);
        make.bottom.equalTo(self.roomNameLabel.mas_top).offset(-6.0);
        make.width.lessThanOrEqualTo(self).multipliedBy(0.6);
    }];
    [self.memberCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-6.0);
        make.left.equalTo(self).offset(6.0);
        make.width.lessThanOrEqualTo(self).multipliedBy(0.38);
    }];
}

- (void)configUI {
    self.layer.cornerRadius = 3.0;
    self.layer.masksToBounds = YES;
    self.backgroundColor = RGB(237, 237, 237);
}


@end
