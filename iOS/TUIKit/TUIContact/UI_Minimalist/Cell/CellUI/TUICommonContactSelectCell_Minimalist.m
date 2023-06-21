
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUICommonContactSelectCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUICommonContactSelectCellData_Minimalist

@end

@interface TUICommonContactSelectCell_Minimalist ()
@property TUICommonContactSelectCellData_Minimalist *selectData;
@end

@implementation TUICommonContactSelectCell_Minimalist

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame {
    frame.size.width = Screen_Width;
    [super setFrame:frame];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.selectButton];
        [self.selectButton setImage:[UIImage imageNamed:TIMCommonImagePath(@"icon_select_normal")] forState:UIControlStateNormal];
        [self.selectButton setImage:[UIImage imageNamed:TIMCommonImagePath(@"icon_select_pressed")] forState:UIControlStateHighlighted];
        [self.selectButton setImage:[UIImage imageNamed:TIMCommonImagePath(@"icon_select_selected")] forState:UIControlStateSelected];
        [self.selectButton setImage:[UIImage imageNamed:TIMCommonImagePath(@"icon_select_selected_disable")] forState:UIControlStateDisabled];
        self.selectButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");

        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.avatarView.mm_width(kScale390(40)).mm_height(kScale390(40)).mm__centerY(self.mm_centerY).mm_left(kScale390(16));
        self.selectButton.mm_sizeToFit().mm__centerY(self.mm_centerY).mm_right(kScale390(kScale390(42)));
        self.titleLabel.mm_left(self.avatarView.mm_maxX + 12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)fillWithData:(TUICommonContactSelectCellData_Minimalist *)selectData {
    [super fillWithData:selectData];
    self.selectData = selectData;
    self.titleLabel.text = selectData.title;
    if (selectData.avatarUrl) {
        [self.avatarView sd_setImageWithURL:selectData.avatarUrl placeholderImage:DefaultAvatarImage];
    } else if (selectData.avatarImage) {
        [self.avatarView setImage:selectData.avatarImage];
    } else {
        [self.avatarView setImage:DefaultAvatarImage];
    }
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    [self.selectButton setSelected:selectData.isSelected];
    self.selectButton.enabled = selectData.enabled;
}

@end
