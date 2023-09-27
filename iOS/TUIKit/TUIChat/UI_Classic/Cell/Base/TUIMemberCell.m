//
//  TUIMemberCell.m
//  TUIChat
//
//  Created by xia on 2022/3/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMemberCell.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUIMemberCellData.h"

@interface TUIMemberCell ()

@property(nonatomic, strong) UIImageView *avatarView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *detailLabel;
@property(nonatomic, strong) TUIMemberCellData *cellData;

@end

@implementation TUIMemberCell

#pragma mark - Life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");

        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");

        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        [self.contentView addSubview:self.detailLabel];
        self.detailLabel.rtlAlignment = TUITextRTLAlignmentTrailing;
        self.detailLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        self.changeColorWhenTouched = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Public
- (void)fillWithData:(TUIMemberCellData *)cellData {
    [super fillWithData:cellData];
    self.cellData = cellData;

    self.titleLabel.text = cellData.title;
    [self.avatarView sd_setImageWithURL:cellData.avatarUrL placeholderImage:DefaultAvatarImage];
    self.detailLabel.hidden = cellData.detail.length == 0;
    self.detailLabel.text = cellData.detail;
    
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
        make.trailing.lessThanOrEqualTo(self.detailLabel.mas_leading).mas_offset(-5);
    }];

    [self.detailLabel sizeToFit];
    [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatarView.mas_centerY);
        make.height.mas_equalTo(20);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-3);
        make.width.mas_equalTo(self.detailLabel.frame.size.width);
    }];
    

}
@end
