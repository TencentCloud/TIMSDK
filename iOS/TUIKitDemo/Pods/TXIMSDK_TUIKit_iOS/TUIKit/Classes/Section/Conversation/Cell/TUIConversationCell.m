//
//  TUIConversationCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TUIConversationCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMUserProfile+DataProvider.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUIKit.h"
#import "THeader.h"
#import "CreatGroupAvatar.h"
#import <ImSDK/ImSDK.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"

@implementation TUIConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];

        _headImageView = [[UIImageView alloc] init];
        [self addSubview:_headImageView];

        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor d_systemGrayColor];
        _timeLabel.layer.masksToBounds = YES;
        [self addSubview:_timeLabel];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        _titleLabel.layer.masksToBounds = YES;
        [self addSubview:_titleLabel];

        _unReadView = [[TUnReadView alloc] init];
        [self addSubview:_unReadView];

        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor d_systemGrayColor];
        [self addSubview:_subTitleLabel];

        [self setSeparatorInset:UIEdgeInsetsMake(0, TConversationCell_Margin, 0, 0)];

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    return self;
}
- (void)fillWithData:(TUIConversationCellData *)convData
{
    [super fillWithData:convData];
    self.convData = convData;

    self.timeLabel.text = [convData.time tk_messageString];
    self.subTitleLabel.attributedText = convData.subTitle;
    [self.unReadView setNum:convData.unreadCount];

    if (convData.isOnTop) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_OnTop dark:TCell_OnTop_Dark];
    } else {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
    }
    
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }

    @weakify(self)
    [[[RACObserve(convData, title) takeUntil:self.rac_prepareForReuseSignal]
      distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.titleLabel.text = x;
    }];
    [[RACObserve(convData,faceUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        if (self.convData.groupID.length > 0) { //群组
            [self getCacheGroupAvatar:^(UIImage *avatar) {
                if (avatar != nil) { //已缓存群组头像
                    self.headImageView.image = avatar;
                } else { //未缓存群组头像
                    [self.headImageView sd_setImageWithURL:x
                                          placeholderImage:self.convData.avatarImage];
                    [self prefetchGroupMembers];
                }
            }];
        } else {//个人头像
            [self.headImageView sd_setImageWithURL:x
                                  placeholderImage:self.convData.avatarImage];
        }
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = [self.convData heightOfWidth:self.mm_w];
    self.mm_h = height;
    CGFloat imgHeight = height-2*(TConversationCell_Margin);

    self.headImageView.mm_width(imgHeight).mm_height(imgHeight).mm_left(TConversationCell_Margin + 3).mm_top(TConversationCell_Margin);
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = imgHeight / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }

    self.timeLabel.mm_sizeToFit().mm_top(TConversationCell_Margin_Text).mm_right(TConversationCell_Margin + 4);
    self.titleLabel.mm_sizeToFitThan(120, 30).mm_top(TConversationCell_Margin_Text - 5).mm_left(self.headImageView.mm_maxX+TConversationCell_Margin);
    self.unReadView.mm_right(TConversationCell_Margin + 4).mm_bottom(TConversationCell_Margin - 1);
    self.subTitleLabel.mm_sizeToFit().mm_left(self.titleLabel.mm_x).mm_bottom(TConversationCell_Margin_Text).mm_flexToRight(self.mm_w-self.unReadView.mm_x);
}

/// 取得群组前9个用户
- (void)prefetchGroupMembers {
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:self.convData.groupID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        int i = 0;
        NSMutableArray *groupMembers = [NSMutableArray arrayWithCapacity:1];
        for (V2TIMGroupMemberFullInfo* member in memberList) {
            if (member.userID.length > 0) {
                [groupMembers addObject:member.userID];
                i++;
            }
            if (i == 9) {
                break;
            }
        }
        [self fetchGroupMembersAvatar:groupMembers];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.convData.faceUrl]
                              placeholderImage:self.convData.avatarImage];
    }];
}

/// 根据头像生成群组图片
/// @param members 群组用户ids
- (void)fetchGroupMembersAvatar:(NSArray*)members {
    @weakify(self)
    [[V2TIMManager sharedInstance] getUsersInfo:members succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        NSMutableArray *groupMemberAvatars = [NSMutableArray arrayWithCapacity:1];
        for (V2TIMGroupMemberFullInfo *profile in infoList) {
            if (profile.faceURL.length > 0) {
                [groupMemberAvatars addObject:profile.faceURL];
            }
        }
        [CreatGroupAvatar createGroupAvatar:groupMemberAvatars finished:^(NSData *groupAvatar) {
            @strongify(self)
            UIImage *avatar = [UIImage imageWithData:groupAvatar];
            self.headImageView.image = avatar;
            [self cacheGroupAvatar:avatar number:(UInt32)members.count];
        }];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.convData.faceUrl]
                              placeholderImage:self.convData.avatarImage];
    }];
}

/// 缓存群组头像
/// @param avatar 图片
/// 取缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化取不到缓存
- (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum {
    if (self.convData.groupID.length == 0) {
        return;
    }
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
                          self.convData.groupID,memberNum];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // check to delete old file
    NSNumber *oldValue = [defaults objectForKey:self.convData.groupID];
    if ( oldValue != nil) {
        UInt32 oldMemberNum = [oldValue unsignedIntValue];
        NSString *oldFilePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath,
        self.convData.groupID,oldMemberNum];
         NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:oldFilePath error:nil];
    }
    
    // Save image.
    BOOL success = [UIImagePNGRepresentation(self.headImageView.image) writeToFile:filePath atomically:YES];
    if (success) {
        [defaults setObject:@(memberNum) forKey:self.convData.groupID];
    }
}

/// 获取缓存群组头像
/// 缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化要引起头像改变
- (void)getCacheGroupAvatar:(void(^)(UIImage *))imageCallBack {
    [[V2TIMManager sharedInstance] getGroupsInfo:@[self.convData.groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *groupInfo = groupResultList.firstObject;
        if (!groupInfo) {
            imageCallBack(nil);
            return;
        }
        UInt32 memberNum = groupInfo.info.memberCount;
        //限定1-9的范围
        memberNum = MAX(1, memberNum);
        memberNum = MIN(memberNum, 9);;
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath,
                              self.convData.groupID,(unsigned int)memberNum];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        UIImage *avatar = nil;
        BOOL success = [fileManager fileExistsAtPath:filePath];

        if (success) {
            avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
        }
        imageCallBack(avatar);
    } fail:^(int code, NSString *msg) {
        imageCallBack(nil);
    }];
}
@end
