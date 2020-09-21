//
//  TUIUserProfileDataProviderService.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//

#import "TUIUserProfileDataProviderService.h"
#import "TIMUserProfile+DataProvider.h"
#import "TCServiceManager.h"
#import "NSString+TUICommon.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import <ImSDK/ImSDK.h>
#import "TUIKit.h"

@TCServiceRegister(TUIUserProfileDataProviderServiceProtocol, TUIUserProfileDataProviderService)

@implementation TUIUserProfileDataProviderService

+ (BOOL)singleton
{
    return YES;
}

+ (id)shareInstance
{
    static TUIUserProfileDataProviderService *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (NSString *)getName:(V2TIMUserFullInfo *)profile
{
    if ([NSString isEmpty:profile.nickName])
        return profile.userID;
    return profile.nickName;
}

- (NSString *)getGender:(V2TIMUserFullInfo *)profile
{
    if (profile.gender == V2TIM_GENDER_MALE)
        return @"男";
    if (profile.gender == V2TIM_GENDER_FEMALE)
        return @"女";
    return @"未设置";
}

- (NSString *)getSignature:(V2TIMUserFullInfo *)profile
{
    if (profile.selfSignature == nil)
        return nil;
    return profile.selfSignature;
}


- (NSString *)getAllowType:(V2TIMUserFullInfo *)profile
{
    if (profile.allowType == V2TIM_FRIEND_ALLOW_ANY) {
        return @"同意任何用户加好友";
    }
    if (profile.allowType == V2TIM_FRIEND_NEED_CONFIRM) {
        return @"需要验证";
    }
    if (profile.allowType == V2TIM_FRIEND_DENY_ANY) {
        return @"拒绝任何人加好友";
    }
    return nil;
}

- (UIImageView *)getAvatarView:(V2TIMUserFullInfo *)profile
{
    UIImageView *avatarView = [[UIImageView alloc] init];

    [avatarView sd_setImageWithURL:[NSURL URLWithString:profile.faceURL] placeholderImage:DefaultAvatarImage];

    return avatarView;
}

@end
