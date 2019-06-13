//
//  TUIUserProfileDataProviderServiceProtocol.h
//  Pods
//
//  Created by annidyfeng on 2019/5/2.
//

#ifndef TUIUserProfileDataProviderServiceProtocol_h
#define TUIUserProfileDataProviderServiceProtocol_h

#import "TCServiceProtocol.h"
@import UIKit;

@class TIMUserProfile;
@protocol TUIUserProfileDataProviderServiceProtocol <TCServiceProtocol>

#pragma mark - TIMUserProfile

- (NSString *)getName:(TIMUserProfile *)profile;

- (NSString *)getGender:(TIMUserProfile *)profile;

- (NSString *)getSignature:(TIMUserProfile *)profile;

- (NSString *)getLocation:(TIMUserProfile *)profile;

- (NSDate *)getBirthday:(TIMUserProfile *)profile;

- (NSString *)getAllowType:(TIMUserProfile *)profile;

- (UIImageView *)getAvatarView:(TIMUserProfile *)profile;

@end

#endif /* TUIUserProfileDataProviderServiceProtocol_h */
