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
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _selectedMark.mm_width(12).mm_height(12).mm_left(12).mm__centerY(self.mm_h / 2);
    _userImg.mm_width(32).mm_height(32).mm_left(_selectedMark.mm_maxX + 12).mm__centerY(self.mm_h / 2);
    _nameLabel.mm_height(self.mm_h).mm_left(_userImg.mm_maxX + 12).mm_flexToRight(0);
}
@end
