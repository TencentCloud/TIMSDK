//
//  TUIContactActionCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//

#import "TUIContactActionCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMUserProfile+DataProvider.h"
#import "THeader.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TCommonContactCellData.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"

@interface TUIContactActionCell ()
@property TUIContactActionCellData *actionData;
@end

@implementation TUIContactActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(34).mm_height(34).mm__centerY(28).mm_left(12);
        if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
        } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
        }

        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_height(20).mm__centerY(self.avatarView.mm_centerY).mm_flexToRight(0);

        self.unRead = [[TUnReadView alloc] init];
        [self.contentView addSubview:self.unRead];

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)fillWithData:(TUIContactActionCellData *)actionData
{
    [super fillWithData:actionData];
    self.actionData = actionData;


    self.titleLabel.text = actionData.title;
    if (actionData.icon) {
        [self.avatarView setImage:actionData.icon];
    }
    @weakify(self)
    [[RACObserve(self.actionData, readNum) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
        @strongify(self)
        [self.unRead setNum:[x integerValue]];
    }];

    self.unRead.mm__centerY(self.avatarView.mm_centerY).mm_right(self.accessoryView.mm_w);
}


@end
