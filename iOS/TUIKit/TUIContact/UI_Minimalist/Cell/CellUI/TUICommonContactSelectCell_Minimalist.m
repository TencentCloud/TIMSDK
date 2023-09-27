
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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    CGFloat imgWidth = kScale390(34);


    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(imgWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(kScale390(12));
    }];
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = imgWidth / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatarView.mas_centerY);
        make.leading.mas_equalTo(self.avatarView.mas_trailing).mas_offset(12);
        make.height.mas_equalTo(20);
        make.trailing.mas_greaterThanOrEqualTo(self.contentView.mas_trailing);
    }];
    
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-kScale390(20));
        make.width.height.mas_equalTo(20);
    }];
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
    [self.selectButton setSelected:selectData.isSelected];
    self.selectButton.enabled = selectData.enabled;
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

@end
