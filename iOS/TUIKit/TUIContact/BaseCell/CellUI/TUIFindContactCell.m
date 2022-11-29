//
//  TUIFindContactCell.m
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//

#import "TUIFindContactCell.h"
#import "UIView+TUILayout.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"
#define kScale UIScreen.mainScreen.bounds.size.width / 375.0

@implementation TUIFindContactCell

-  (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.mainTitleLabel];
    [self.contentView addSubview:self.subTitleLabel];
    [self.contentView addSubview:self.descLabel];
}

- (void)setData:(TUIFindContactCellModel *)data {
    _data = data;
    
    self.mainTitleLabel.text = data.mainTitle;
    self.subTitleLabel.text = data.subTitle;
    self.descLabel.text = data.desc;
    UIImage *placeHolder =  (data.type == TUIFindContactTypeC2C)?DefaultAvatarImage:DefaultGroupAvatarImageByGroupType(data.groupInfo.groupType);
    [self.avatarView sd_setImageWithURL:data.avatarUrl placeholderImage:data.avatar?:placeHolder];
    
    self.descLabel.hidden = (data.type == TUIFindContactTypeC2C);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarView.mm_left(16 * kScale).mm_top(12 * kScale).mm_width(48 * kScale).mm_height(48 * kScale);
    self.mainTitleLabel.mm_sizeToFit();
    self.mainTitleLabel.mm_x = CGRectGetMaxX(self.avatarView.frame) + 12 * kScale;
    self.mainTitleLabel.mm_y = self.avatarView.mm_y;
    self.mainTitleLabel.mm_flexToRight(12 * kScale);
    
    self.subTitleLabel.mm_sizeToFit();
    self.subTitleLabel.mm_x = self.mainTitleLabel.mm_x;
    self.subTitleLabel.mm_y = CGRectGetMaxY(self.mainTitleLabel.frame) + 2 * kScale;
    self.subTitleLabel.mm_flexToRight(12 * kScale);
    
    self.descLabel.mm_sizeToFit();
    self.descLabel.mm_x = self.mainTitleLabel.mm_x;
    self.descLabel.mm_y = CGRectGetMaxY(self.subTitleLabel.frame) + 2 * kScale;
    self.descLabel.mm_flexToRight(12 * kScale);
}

- (UIImageView *)avatarView {
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 3 * kScale;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

- (UILabel *)mainTitleLabel {
    if (_mainTitleLabel == nil) {
        _mainTitleLabel = [[UILabel alloc] init];
        _mainTitleLabel.text = @"mainTitle";
        _mainTitleLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
        _mainTitleLabel.font = [UIFont systemFontOfSize:18.0 * kScale];
    }
    return _mainTitleLabel;
}

- (UILabel *)subTitleLabel {
    if (_subTitleLabel == nil) {
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.text = @"subTitle";
        _subTitleLabel.textColor =  TUICoreDynamicColor(@"form_subtitle_color", @"#888888");
        _subTitleLabel.font = [UIFont systemFontOfSize:13.0 * kScale];
    }
    return _subTitleLabel;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"descLabel";
        _descLabel.textColor = TUICoreDynamicColor(@"form_desc_color", @"#888888");
        _descLabel.font = [UIFont systemFontOfSize:13.0 * kScale];
    }
    return _descLabel;
}

@end
