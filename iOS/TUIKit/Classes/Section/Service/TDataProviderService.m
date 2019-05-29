//
//  TDataProviderService.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//

#import "TDataProviderService.h"
#import "TIMUserProfile+DataProvider.h"
#import "TCServiceManager.h"
#import "NSString+Common.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "THeader.h"
#import <ImSDK/ImSDK.h>

@TCServiceRegister(TDataProviderServiceProtocol, TDataProviderService)

@implementation TDataProviderService

+ (BOOL)singleton
{
    return YES;
}

+ (id)shareInstance
{
    static TDataProviderService *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (NSString *)getName:(TIMUserProfile *)profile
{
    if ([NSString isEmpty:profile.nickname])
        return profile.identifier;
    return profile.nickname;
}

- (NSString *)getGender:(TIMUserProfile *)profile
{
    if (profile.gender == TIM_GENDER_MALE)
        return @"男";
    if (profile.gender == TIM_GENDER_FEMALE)
        return @"女";
    return @"未知";
}

- (NSString *)getSignature:(TIMUserProfile *)profile
{
    if (profile.selfSignature == nil)
        return nil;
    
    return [NSString stringWithUTF8String:profile.selfSignature.bytes];;
}

- (NSString *)getLocation:(TIMUserProfile *)profile
{
    if (profile.location == nil)
        return nil;
    
    return [NSString stringWithUTF8String:profile.location.bytes];
}

- (NSString *)getAllowType:(TIMUserProfile *)profile
{
    if (profile.allowType == TIM_FRIEND_ALLOW_ANY) {
        return @"同意任何用户加好友";
    }
    if (profile.allowType == TIM_FRIEND_NEED_CONFIRM) {
        return @"需要验证";
    }
    if (profile.allowType == TIM_FRIEND_DENY_ANY) {
        return @"拒绝任何人加好友";
    }
    return nil;
}

- (NSDate *)getBirthday:(TIMUserProfile *)profile
{
    if (profile.birthday == 0)
        return nil;
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = profile.birthday % 100;
    dateComponents.month = (profile.birthday / 100) % 100;
    dateComponents.year = (profile.birthday / 10000) % 10000;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorianCalendar dateFromComponents:dateComponents];
    
    return date;
}

- (void)setBirthday:(NSDate *)date to:(TIMUserProfile *)profile
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *dateComponents = [gregorianCalendar components:unitFlags fromDate:date];
    
    profile.birthday = (uint32_t)(dateComponents.year * 10000 + dateComponents.month * 100 + dateComponents.day);
}

- (UIImageView *)getAvatarView:(TIMUserProfile *)profile
{
    UIImageView *avatarView = [[UIImageView alloc] init];
    
    [avatarView sd_setImageWithURL:[NSURL URLWithString:profile.faceURL] placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_head")]];
    
    return avatarView;
}

@end
