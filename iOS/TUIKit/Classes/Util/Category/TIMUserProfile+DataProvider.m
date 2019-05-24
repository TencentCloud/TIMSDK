//
//  TIMUserProfile+Presentation.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/2.
//

#import "TIMUserProfile+DataProvider.h"
#import "TCServiceManager.h"
#import "TDataProviderService.h"

@implementation TIMUserProfile (DataProvider)

- (NSString *)showName
{
    id<TDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TDataProviderServiceProtocol)];
    return [expr getName:self];
}

- (NSString *)showGender
{
    id<TDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TDataProviderServiceProtocol)];
    return [expr getGender:self];
}

- (NSString *)showSignature
{
    id<TDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TDataProviderServiceProtocol)];
    return [expr getSignature:self];
}

- (NSString *)showLocation
{
    id<TDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TDataProviderServiceProtocol)];
    return [expr getLocation:self];
}

- (NSDate *)showBirthday
{
    id<TDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TDataProviderServiceProtocol)];
    return [expr getBirthday:self];
}

- (NSString *)showAllowType
{
    id<TDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TDataProviderServiceProtocol)];
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
    id<TDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TDataProviderServiceProtocol)];
    return [expr getAvatarView:self];
}

@end
