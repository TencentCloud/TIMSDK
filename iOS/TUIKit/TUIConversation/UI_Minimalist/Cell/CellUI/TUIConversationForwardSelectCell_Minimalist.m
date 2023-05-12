//
//  TUIConversationForwardSelectCell_Minimalist.m
//  TUIConversation
//
//  Created by wyl on 2023/1/31.
//

#import "TUIConversationForwardSelectCell_Minimalist.h"
#import <TIMCommon/TUIGroupAvatar+Helper.h>
@interface TUIConversationForwardSelectCell_Minimalist()

@end

@implementation TUIConversationForwardSelectCell_Minimalist
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
        self.selectButton.userInteractionEnabled = NO;
        
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");

        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

        self.avatarView.mm_width(kScale390(40)).mm_height(kScale390(40)).mm__centerY(self.mm_centerY).mm_left(kScale390(16));
        self.selectButton.mm_sizeToFit().mm__centerY(self.mm_centerY).mm_right(kScale390(kScale390(42)));
        self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)fillWithData:(TUIConversationCellData *)selectData {
    self.selectData = selectData;
    self.titleLabel.text = selectData.title;
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    [self configHeadImageView:selectData];
    [self.selectButton setSelected:selectData.selected];
    if (selectData.showCheckBox) {
        self.selectButton.hidden = NO;
    }
    else {
        self.selectButton.hidden = YES;
    }
//    self.selectButton.enabled = selectData.enabled;
}


- (void)configHeadImageView:(TUIConversationCellData *)convData {
    
    /**
     * 修改默认头像
     * Setup default avatar
     */
    if (convData.groupID.length > 0) {
        /**
         * 群组, 则将群组默认头像修改成上次使用的头像
         * If it is a group, change the group default avatar to the last used avatar
         */
        convData.avatarImage = [TUIGroupAvatar getNormalGroupCacheAvatar:convData.groupID groupType:convData.groupType];
    }
    
    @weakify(self);

    [[RACObserve(convData,faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *faceUrl) {
        @strongify(self)
        NSString * groupID = convData.groupID?:@"";
        NSString * pFaceUrl = convData.faceUrl?:@"";
        NSString * groupType = convData.groupType?:@"";
        UIImage * originAvatarImage = nil;
        if (convData.groupID.length > 0) {
            originAvatarImage = convData.avatarImage?:DefaultGroupAvatarImageByGroupType(groupType);
        }
        else {
            originAvatarImage = convData.avatarImage?:DefaultAvatarImage;
        }
        NSDictionary *param =  @{
            @"groupID":groupID,
            @"faceUrl":pFaceUrl,
            @"groupType":groupType,
            @"originAvatarImage":originAvatarImage,
        };
        [TUIGroupAvatar configAvatarByParam:param targetView:self.avatarView];
    }];
}
@end
