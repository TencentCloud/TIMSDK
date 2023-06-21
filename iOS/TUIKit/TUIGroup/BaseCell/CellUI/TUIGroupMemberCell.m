
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import "TUIGroupMemberCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/UIView+TUILayout.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation TUIGroupMemberCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews {
    _head = [[UIImageView alloc] init];
    _head.layer.cornerRadius = 5;
    [_head.layer setMasksToBounds:YES];
    [self.contentView addSubview:_head];

    _name = [[UILabel alloc] init];
    [_name setFont:[UIFont systemFontOfSize:13]];
    [_name setTextColor:[UIColor grayColor]];
    _name.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_name];
}

- (void)defaultLayout {
    CGSize headSize = [[self class] getSize];
    _head.frame = CGRectMake(0, 0, headSize.width, headSize.width);
    _name.frame = CGRectMake(0, _head.frame.origin.y + _head.frame.size.height + TGroupMemberCell_Margin, _head.frame.size.width, TGroupMemberCell_Name_Height);
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        _head.layer.masksToBounds = YES;
        _head.layer.cornerRadius = _head.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        _head.layer.masksToBounds = YES;
        _head.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
}

- (void)setData:(TUIGroupMemberCellData *)data {
    _data = data;

    if (data.avatarUrl) {
        [self.head sd_setImageWithURL:[NSURL URLWithString:data.avatarUrl] placeholderImage:data.avatarImage ?: DefaultAvatarImage];
    } else {
        if (data.avatarImage) {
            self.head.image = data.avatarImage;
        } else {
            self.head.image = DefaultAvatarImage;
        }
    }
    if (data.name.length) {
        self.name.text = data.name;
    } else {
        self.name.text = data.identifier;
    }
    [self defaultLayout];
}

+ (CGSize)getSize {
    CGSize headSize = TGroupMemberCell_Head_Size;
    if (headSize.width * TGroupMembersCell_Column_Count + TGroupMembersCell_Margin * (TGroupMembersCell_Column_Count + 1) > Screen_Width) {
        CGFloat wd = (Screen_Width - (TGroupMembersCell_Margin * (TGroupMembersCell_Column_Count + 1))) / TGroupMembersCell_Column_Count;
        headSize = CGSizeMake(wd, wd);
    }
    return CGSizeMake(headSize.width, headSize.height + TGroupMemberCell_Name_Height + TGroupMemberCell_Margin);
}
@end
