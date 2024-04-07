//
//  TUIGroupProfileCardViewCell.m
//  TUIGroup
//
//  Created by wyl on 2023/1/3.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupProfileCardViewCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIGroupAvatar+Helper.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIGroupProfileHeaderItemView_Minimalist
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}
- (void)setupView {
    self.iconView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self addSubview:self.iconView];
    self.iconView.userInteractionEnabled = YES;
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;

    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:kScale390(16)];
    self.textLabel.rtlAlignment = TUITextRTLAlignmentCenter;
    self.textLabel.textColor = [UIColor tui_colorWithHex:@"#000000"];
    self.textLabel.userInteractionEnabled = YES;
    [self addSubview:self.textLabel];
    self.textLabel.text = @"Message";

    self.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
    self.layer.cornerRadius = kScale390(12);
    self.layer.masksToBounds = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [self addGestureRecognizer:tap];
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kScale390(30));
        make.top.mas_equalTo(kScale390(19));
        make.centerX.mas_equalTo(self);
    }];
    [self.textLabel sizeToFit];
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(kScale390(19));
        make.top.mas_equalTo(self.iconView.mas_bottom).mas_offset(kScale390(11));
        make.centerX.mas_equalTo(self);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];

}
- (void)click {
    if (self.messageBtnClickBlock) {
        self.messageBtnClickBlock();
    }
}
@end

@interface TUIGroupProfileHeaderView_Minimalist ()
@end

@implementation TUIGroupProfileHeaderView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.headImg = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self addSubview:self.headImg];
    self.headImg.userInteractionEnabled = YES;
    self.headImg.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageClick)];
    [self.headImg addGestureRecognizer:tap];

    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.font = [UIFont boldSystemFontOfSize:kScale390(24)];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.userInteractionEnabled = YES;
    [self addSubview:self.descriptionLabel];

    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self addSubview:self.editButton];
    [self.editButton setImage:[UIImage imageNamed:TUIGroupImagePath(@"icon_group_edit")] forState:UIControlStateNormal];
    [self.editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.editButton.hidden = YES;

    self.idLabel = [[UILabel alloc] init];
    self.idLabel.font = [UIFont systemFontOfSize:kScale390(12)];
    self.idLabel.textColor = [UIColor tui_colorWithHex:@"666666"];
    self.idLabel.textAlignment = NSTextAlignmentCenter;
    self.idLabel.userInteractionEnabled = YES;
    [self addSubview:self.idLabel];

    self.functionListView = [[UIView alloc] init];
    self.functionListView.userInteractionEnabled = YES;
    [self addSubview:self.functionListView];
}

- (void)setGroupInfo:(V2TIMGroupInfo *)groupInfo {
    _groupInfo = groupInfo;
    [self.headImg sd_setImageWithURL:[NSURL URLWithString:self.groupInfo.faceURL]
                    placeholderImage:DefaultGroupAvatarImageByGroupType(self.groupInfo.groupType)];
    [self configHeadImageView:groupInfo];
    
    self.descriptionLabel.text = groupInfo.groupName;
    self.idLabel.text = self.groupInfo.groupID;
    if ([self.class isMeSuper:groupInfo]) {
        self.editButton.hidden = NO;
    }

    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}
- (void)configHeadImageView:(V2TIMGroupInfo *)groupInfo {
    /**
     * Setup default avatar
     */
    if (groupInfo.groupID.length > 0) {
        /**
         * If it is a group, change the group default avatar to the last used avatar
         */
        [self.headImg sd_setImageWithURL:[NSURL URLWithString:self.groupInfo.faceURL]
                        placeholderImage:DefaultGroupAvatarImageByGroupType(self.groupInfo.groupType)];
    }

    @weakify(self);
    NSString *groupID = groupInfo.groupID ?: @"";
    NSString *pFaceUrl = groupInfo.faceURL ?: @"";
    NSString *groupType = groupInfo.groupType ?: @"";
    UIImage *originAvatarImage = DefaultGroupAvatarImageByGroupType(self.groupInfo.groupType) ?: [UIImage new];

    NSDictionary *param = @{
        @"groupID" : groupID,
        @"faceUrl" : pFaceUrl,
        @"groupType" : groupType,
        @"originAvatarImage" : originAvatarImage,
    };
    [TUIGroupAvatar configAvatarByParam:param targetView:self.headImg];
}

- (void)setItemViewList:(NSArray<TUIGroupProfileHeaderItemView_Minimalist *> *)itemList {
    for (UIView *subView in self.functionListView.subviews) {
        [subView removeFromSuperview];
    }
    if (itemList.count > 0) {
        for (TUIGroupProfileHeaderItemView_Minimalist *itemView in itemList) {
            [self.functionListView addSubview:itemView];
        }
        CGFloat width = kScale390(92);
        CGFloat height = kScale390(95);
        CGFloat space = kScale390(18);
        CGFloat contentWidth = itemList.count * width + (itemList.count - 1) * space;
        CGFloat x = 0.5 * (self.bounds.size.width - contentWidth);
        for (TUIGroupProfileHeaderItemView_Minimalist *itemView in itemList) {
            itemView.frame = CGRectMake(x, 0, width, height);
            x = CGRectGetMaxX(itemView.frame) + space;
        }
    }
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    CGFloat imgWidth = kScale390(94);
    [self.headImg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(imgWidth);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(kScale390(42));
    }];
    
    MASAttachKeys(self.headImg);

    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = imgWidth / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.headImg.mas_bottom).mas_offset(kScale390(10));
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(self.descriptionLabel.frame.size.width);
        make.width.mas_lessThanOrEqualTo(self).multipliedBy(0.5);
    }];
    MASAttachKeys(self.descriptionLabel);

    [self.editButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.descriptionLabel.mas_trailing).mas_equalTo(kScale390(3));
        make.top.mas_equalTo(self.descriptionLabel.mas_top);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
    }];
    MASAttachKeys(self.editButton);
    
    [self.idLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading);
        make.top.mas_equalTo(self.descriptionLabel.mas_bottom).mas_offset(kScale390(8));
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(self.frame.size.width);
    }];
    if (self.functionListView.subviews.count > 0) {
        [self.functionListView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(0);
            make.width.mas_equalTo(self.bounds.size.width);
            make.height.mas_equalTo(kScale390(95));
            make.top.mas_equalTo(self.idLabel.mas_bottom).mas_offset(kScale390(18));
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)headImageClick {
    if (self.headImgClickBlock && [self.class isMeSuper:self.groupInfo]) {
        self.headImgClickBlock();
    }
}

- (void)editButtonClick {
    if (self.editBtnClickBlock && [self.class isMeSuper:self.groupInfo]) {
        self.editBtnClickBlock();
    }
}

+ (BOOL)isMeSuper:(V2TIMGroupInfo *)groupInfo {
    return [groupInfo.owner isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]] && (groupInfo.role == V2TIM_GROUP_MEMBER_ROLE_SUPER);
}
@end

@implementation TUIGroupProfileCardViewCell_Minimalist

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.headerView = [[TUIGroupProfileHeaderView_Minimalist alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, kScale390(355))];

    [self.contentView addSubview:self.headerView];
}

- (void)fillWithData:(TUIGroupProfileCardCellData_Minimalist *)data {
    [super fillWithData:data];
    self.cardData = data;

    [self.headerView.headImg sd_setImageWithURL:data.avatarUrl placeholderImage:data.avatarImage];
    self.headerView.descriptionLabel.text = data.name;
    self.headerView.idLabel.text = [NSString stringWithFormat:@"ID: %@", data.identifier];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.headerView.functionListView.subviews.count > 0) {
        self.headerView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, kScale390(355));
    } else {
        self.headerView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, kScale390(257));
    }
    [self.headerView.descriptionLabel sizeToFit];
    self.headerView.itemViewList = self.itemViewList;
}

@end
