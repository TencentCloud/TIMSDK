//
//  TIMUserProfile+Presentation.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/2.
//

#import "TIMUserProfile+DataProvider.h"
#import "TCServiceManager.h"
#import "TUIUserProfileDataProviderServiceProtocol.h"

@implementation TIMUserProfile (DataProvider)

- (NSString *)showName
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getName:self];
}

- (NSString *)showGender
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getGender:self];
}

- (NSString *)showSignature
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getSignature:self];
}

- (NSString *)showLocation
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getLocation:self];
}

- (NSDate *)showBirthday
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getBirthday:self];
}

- (NSString *)showAllowType
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getAllowType:self];
}

- (void)setShowBirthday:(NSDate *)date
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *dateComponents = [gregorianCalendar components:unitFlags fromDate:date];
    
    self.birthday = (uint32_t)(dateComponents.year * 10000 + dateComponents.month * 100 + dateComponents.day);
}

- (UIImageView *)avatarView
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getAvatarView:self];
}

@end
