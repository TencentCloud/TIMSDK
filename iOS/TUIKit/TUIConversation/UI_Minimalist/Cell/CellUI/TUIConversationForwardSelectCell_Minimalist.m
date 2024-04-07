//
//  TUIConversationForwardSelectCell_Minimalist.m
//  TUIConversation
//
//  Created by wyl on 2023/1/31.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationForwardSelectCell_Minimalist.h"
#import <TIMCommon/TUIGroupAvatar+Helper.h>
@interface TUIConversationForwardSelectCell_Minimalist ()

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
    CGFloat imgWidth = kScale390(40);
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(imgWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(kScale390(16));
    }];
    if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = imgWidth / 2;
    } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
        self.avatarView.layer.masksToBounds = YES;
        self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
    }
    
    [self.selectButton sizeToFit];
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-kScale390(42));
        make.size.mas_equalTo(self.selectButton.frame.size);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.avatarView.mas_centerY);
        make.leading.mas_equalTo(self.avatarView.mas_trailing).mas_offset(12);
        make.height.mas_equalTo(20);
        make.trailing.mas_greaterThanOrEqualTo(self.contentView.mas_trailing);
        
    }];    
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)fillWithData:(TUIConversationCellData *)selectData {
    self.selectData = selectData;
    self.titleLabel.text = selectData.title;
    [self configHeadImageView:selectData];
    [self.selectButton setSelected:selectData.selected];
    if (selectData.showCheckBox) {
        self.selectButton.hidden = NO;
    } else {
        self.selectButton.hidden = YES;
    }
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)configHeadImageView:(TUIConversationCellData *)convData {
    /**
     * Setup default avatar
     */
    if (convData.groupID.length > 0) {
        /**
         * If it is a group, change the group default avatar to the last used avatar
         */
        convData.avatarImage = [TUIGroupAvatar getNormalGroupCacheAvatar:convData.groupID groupType:convData.groupType];
    }

    @weakify(self);

    [[RACObserve(convData, faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSString *faceUrl) {
      @strongify(self);
      NSString *groupID = convData.groupID ?: @"";
      NSString *pFaceUrl = convData.faceUrl ?: @"";
      NSString *groupType = convData.groupType ?: @"";
      UIImage *originAvatarImage = nil;
      if (convData.groupID.length > 0) {
          originAvatarImage = convData.avatarImage ?: DefaultGroupAvatarImageByGroupType(groupType);
      } else {
          originAvatarImage = convData.avatarImage ?: DefaultAvatarImage;
      }
      NSDictionary *param = @{
          @"groupID" : groupID,
          @"faceUrl" : pFaceUrl,
          @"groupType" : groupType,
          @"originAvatarImage" : originAvatarImage,
      };
      [TUIGroupAvatar configAvatarByParam:param targetView:self.avatarView];
    }];
}
@end
