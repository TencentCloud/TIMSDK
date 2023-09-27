//
//  TUICallKitSelectGroupMemberCell.m
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/7.
//  Copyright © 2021 Tencent. All rights reserved

#import "TUICallKitSelectGroupMemberCell.h"
#import "TUICore.h"
#import "UIColor+TUICallingHex.h"
#import "Masonry.h"
#import "TUICallKitGroupMemberInfo.h"
#import "TUICallingCommon.h"
#import "TUICallKitConstants.h"
#import "UIImageView+WebCache.h"
#import "TUIThemeManager.h"

@interface TUICallKitSelectGroupMemberCell ()

@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) TUICallKitGroupMemberInfo *userInfo;

@end

@implementation TUICallKitSelectGroupMemberCell {
    BOOL _isViewReady;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _isViewReady = NO;
        self.contentView.backgroundColor = TUICallKitDynamicColor(@"callkit_recents_cell_bg_color", @"#FFFFFF");
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self activateConstraints];
    _isViewReady = YES;
}

- (void)constructViewHierarchy {
    [self.contentView addSubview:self.userImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectImageView];
}

- (void)activateConstraints {
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(20);
        make.width.height.equalTo(@(15));
        make.centerY.equalTo(self);
    }];
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.selectImageView.mas_trailing).offset(20);
        make.width.height.equalTo(@(40));
        make.centerY.equalTo(self);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.userImageView.mas_trailing).offset(12);
        make.centerY.equalTo(self);
    }];
}

- (void)configCell:(TUICallKitGroupMemberInfo *)userInfo isAdded:(BOOL)isAdded {
    self.userInfo = userInfo;
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar]
                          placeholderImage:[TUICallingCommon getBundleImageWithName:@"userIcon"]];
    
    if (userInfo.isSelect) {
        self.selectImageView.image = [TUICallingCommon getBundleImageWithName:@"tuicallkit_check_box_group_selected"];
    } else {
        self.selectImageView.image = [TUICallingCommon getBundleImageWithName:@"tuicallkit_check_box_group_unselected"];
    }
    
    if (userInfo.name == NULL || [userInfo.name isEqual:@""]) {
        self.nameLabel.text = userInfo.userId;
    } else {
        self.nameLabel.text = userInfo.name;
    }
}

#pragma mark - Lazy

- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.layer.cornerRadius = 10;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = TUICallKitDynamicColor(@"callkit_recents_cell_title_color", @"#000000");
        _nameLabel.backgroundColor = UIColor.clearColor;
    }
    return _nameLabel;
}

- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _selectImageView;
}

@end
