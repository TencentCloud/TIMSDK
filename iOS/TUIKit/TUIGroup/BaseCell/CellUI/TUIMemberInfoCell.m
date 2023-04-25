//
//  TUIMemberInfoCell.m
//  TUIGroup
//
//  Created by harvy on 2021/12/27.
//

#import "TUIMemberInfoCell.h"
#import <TUICore/UIView+TUILayout.h>
#import "TUIMemberInfoCellData.h"
#import "UIImageView+WebCache.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

#define kScale UIScreen.mainScreen.bounds.size.width / 375.0
@implementation TUIMemberTagView : UIView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor tui_colorWithHex:@"#E7F3FC"];
        self.layer.borderWidth = kScale390(1);
        self.layer.cornerRadius = kScale390(3);
        self.layer.borderColor = [UIColor tui_colorWithHex:@"#1890FF"].CGColor;
        [self addSubview:self.tagname];
    }
    return self;
}

- (UILabel *)tagname {
    if (!_tagname) {
        _tagname = [[UILabel alloc] init];
        _tagname.text = @"";
        _tagname.textColor = [UIColor tui_colorWithHex:@"#1890FF"];
        _tagname.font = [UIFont systemFontOfSize:kScale390(10)];
    }
    return _tagname;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [_tagname sizeToFit];
    _tagname.frame = CGRectMake(kScale390(8), 0, _tagname.frame.size.width, self.frame.size.height);
    
}

@end


@implementation TUIMemberInfoCell

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
    [self.contentView addSubview:self.tagView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
}

- (void)setData:(TUIMemberInfoCellData *)data
{
    _data = data;
    
    UIImage *defaultImage = DefaultAvatarImage;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:data.avatarUrl] placeholderImage:data.avatar?:defaultImage];
    self.nameLabel.text = data.name;
    self.tagView.hidden = NO;
    if (data.role == V2TIM_GROUP_MEMBER_ROLE_SUPER) {
        self.tagView.tagname.text = TIMCommonLocalizableString(TUIKitMembersRoleSuper);
    }
    else if (data.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
        self.tagView.tagname.text = TIMCommonLocalizableString(TUIKitMembersRoleAdmin);
    }
    else {
        self.tagView.tagname.text = @"";
        self.tagView.hidden = YES;
    }

    if (data.showAccessory) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
        
    }
    [self updateUI];
}

- (void)updateUI
{
    if (self.data.style == TUIMemberInfoCellStyleAdd) {
        self.avatarImageView.mm_width(20.0 * kScale).mm_height(20.0 * kScale);
        self.avatarImageView.mm_left(18.0 * kScale);
        self.nameLabel.font = [UIFont systemFontOfSize:16.0 * kScale];
        self.nameLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");
    } else {
        self.avatarImageView.mm_width(34.0 * kScale).mm_height(34.0 * kScale);
        self.avatarImageView.mm_left(16.0 * kScale);
        self.nameLabel.font = [UIFont systemFontOfSize:16.0 * kScale];
        self.nameLabel.textColor = TIMCommonDynamicColor(@"form_value_text_color", @"#000000");
    }
    
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarImageView.layer.masksToBounds = YES;
        self.avatarImageView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    self.avatarImageView.mm_centerY = self.contentView.mm_centerY;
    [self.nameLabel sizeToFit];
    self.nameLabel.mm_height(self.contentView.mm_h).mm_left(CGRectGetMaxX(self.avatarImageView.frame) + 14);
    [self.tagView.tagname sizeToFit];
    self.tagView.frame = CGRectMake(self.nameLabel.frame.origin.x + self.nameLabel.frame.size.width +kScale390(10), 0, self.tagView.tagname.frame.size.width + kScale390(16), kScale390(15));
    self.tagView.mm_centerY = self.contentView.mm_centerY;
        
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

- (TUIMemberTagView *)tagView {
    if (_tagView == nil) {
        _tagView = [[TUIMemberTagView alloc] init];
    }
    return _tagView;
}



@end
