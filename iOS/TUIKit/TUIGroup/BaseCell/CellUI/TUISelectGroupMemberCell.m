//
//  TUISelectMemberCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/8/26.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISelectGroupMemberCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUISelectGroupMemberCell {
    UIImageView *_selectedMark;
    UIImageView *_userImg;
    UILabel *_nameLabel;
    TUIUserModel *_userModel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#F2F3F5");
        _selectedMark = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_selectedMark];
        _userImg = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_userImg];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        [self addSubview:_nameLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(TUIUserModel *)model isSelect:(BOOL)isSelect {
    _userModel = model;
    _selectedMark.image = isSelect ? [UIImage imageNamed:TUIGroupImagePath(@"ic_selected")] : [UIImage imageNamed:TUIGroupImagePath(@"ic_unselect")];
    [_userImg sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:DefaultAvatarImage];
    _nameLabel.text = model.name;
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    
    [_selectedMark mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.leading.mas_equalTo(self.contentView).mas_offset(12);
        make.centerY.mas_equalTo(self.contentView);
    }];

    [_userImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(32);
        make.leading.mas_equalTo(_selectedMark.mas_trailing).mas_offset(12);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [_nameLabel sizeToFit];
    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_userImg.mas_trailing).mas_offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(self.contentView);
        make.centerY.mas_equalTo(self.contentView);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
}
@end
