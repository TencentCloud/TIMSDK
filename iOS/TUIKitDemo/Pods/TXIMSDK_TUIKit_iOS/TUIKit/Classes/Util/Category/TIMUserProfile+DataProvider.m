//
//  TIMUserProfile+Presentation.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/2.
//

#import "TIMUserProfile+DataProvider.h"
#import "TCServiceManager.h"
#import "TUIUserProfileDataProviderServiceProtocol.h"

@implementation V2TIMUserFullInfo (DataProvider)

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

- (NSString *)showAllowType
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getAllowType:self];
}

- (UIImageView *)avatarView
{
    id<TUIUserProfileDataProviderServiceProtocol> expr = [[TCServiceManager shareInstance] createService:@protocol(TUIUserProfileDataProviderServiceProtocol)];
    return [expr getAvatarView:self];
}

@end
