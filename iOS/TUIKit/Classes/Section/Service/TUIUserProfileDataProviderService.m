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
#import "TUIKit.h"
#import "NSBundle+TUIKIT.h"

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
        return TUILocalizableString(Male);
    if (profile.gender == V2TIM_GENDER_FEMALE)
        return TUILocalizableString(Female);
    return TUILocalizableString(Unsetted);
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
        return TUILocalizableString(TUIKitAllowTypeAcceptOne);
    }
    if (profile.allowType == V2TIM_FRIEND_NEED_CONFIRM) {
        return TUILocalizableString(TUIKitAllowTypeNeedConfirm);
    }
    if (profile.allowType == V2TIM_FRIEND_DENY_ANY) {
        return TUILocalizableString(TUIKitAllowTypeDeclineAll);
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
