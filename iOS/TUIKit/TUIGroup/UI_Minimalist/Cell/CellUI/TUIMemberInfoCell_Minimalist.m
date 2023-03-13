//
//  TUIMemberInfoCell_Minimalist.m
//  TUIGroup
//
//  Created by wyl on 2023/1/9.
//

#import "TUIMemberInfoCell_Minimalist.h"
#import "UIView+TUILayout.h"
#import "TUIMemberInfoCellData.h"
#import "UIImageView+WebCache.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@implementation TUIMemberInfoCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.nameLabel];
}

- (void)setData:(TUIMemberInfoCellData_Minimalist *)data
{
    _data = data;
    
    UIImage *defaultImage = TUIConfig.defaultConfig.defaultAvatarImage;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:data.avatarUrl] placeholderImage:data.avatar?:defaultImage];
    self.nameLabel.text = data.name;
    
    [self updateUI];
}

- (void)updateUI
{
    if (self.data.style == TUIMemberInfoCellStyleAdd) {
        self.avatarImageView.mm_width(20.0 * kScale).mm_height(20.0 * kScale);
        self.avatarImageView.mm_left(18.0 * kScale);
        self.nameLabel.font = [UIFont systemFontOfSize:16.0 * kScale];
        self.nameLabel.textColor = [UIColor tui_colorWithHex:@"#147AFF"];
    } else {
        self.avatarImageView.mm_width(34.0 * kScale).mm_height(34.0 * kScale);
        self.avatarImageView.mm_left(16.0 * kScale);
        self.nameLabel.font = [UIFont systemFontOfSize:16.0 * kScale];
        self.nameLabel.textColor = TUICoreDynamicColor(@"form_value_text_color", @"#000000");
    }
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    self.avatarImageView.mm_centerY = self.contentView.mm_centerY;
    self.nameLabel.mm_height(self.contentView.mm_h).mm_left(CGRectGetMaxX(self.avatarImageView.frame) + 14).mm_flexToRight(16 * kScale);
}

- (UIImageView *)avatarImageView
{
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:18.0 * kScale];
        _nameLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1/1.0];
    }
    return _nameLabel;
}




@end
