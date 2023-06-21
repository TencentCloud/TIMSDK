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
- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconView.frame = CGRectMake((self.bounds.size.width - kScale390(30)) * 0.5, kScale390(19), kScale390(30), kScale390(30));
    [self.textLabel sizeToFit];
    self.textLabel.frame = CGRectMake((self.bounds.size.width - self.textLabel.frame.size.width) * 0.5,
                                      self.iconView.frame.origin.y + self.iconView.frame.size.height + kScale390(11), self.bounds.size.width, kScale390(19));
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
    [self.descriptionLabel sizeToFit];
    self.idLabel.text = self.groupInfo.groupID;
    if ([self.class isMeSuper:groupInfo]) {
        self.editButton.hidden = NO;
    }
    [self setNeedsLayout];
}
- (void)configHeadImageView:(V2TIMGroupInfo *)groupInfo {
    /**
     * 修改默认头像
     * Setup default avatar
     */
    if (groupInfo.groupID.length > 0) {
        /**
         * 群组, 则将群组默认头像修改成上次使用的头像
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

- (void)layoutSubviews {
    [super layoutSubviews];

    self.headImg.frame = CGRectMake((self.bounds.size.width - kScale390(94)) * 0.5, kScale390(42), kScale390(94), kScale390(94));
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = self.headImg.frame.size.height / 2.0;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.headImg.layer.masksToBounds = YES;
        self.headImg.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }

    [self.descriptionLabel sizeToFit];
    CGFloat descriptionLabelWidth = MIN(self.descriptionLabel.frame.size.width, self.bounds.size.width * 0.5);
    self.descriptionLabel.frame = CGRectMake((self.bounds.size.width - descriptionLabelWidth) * 0.5,
                                             self.headImg.frame.origin.y + self.headImg.frame.size.height + kScale390(10), descriptionLabelWidth, 30);
    self.editButton.frame = CGRectMake(self.descriptionLabel.frame.origin.x + self.descriptionLabel.frame.size.width + kScale390(3),
                                       self.descriptionLabel.frame.origin.y, kScale390(30), kScale390(30));
    self.idLabel.frame =
        CGRectMake(0, self.descriptionLabel.frame.origin.y + self.descriptionLabel.frame.size.height + kScale390(8), self.bounds.size.width, 30);

    if (self.functionListView.subviews.count > 0) {
        self.functionListView.frame = CGRectMake(0, CGRectGetMaxY(self.idLabel.frame) + kScale390(18), self.bounds.size.width, kScale390(95));
    }
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
