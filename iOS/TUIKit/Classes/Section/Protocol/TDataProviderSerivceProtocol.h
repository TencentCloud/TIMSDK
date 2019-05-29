//
//  TDataProviderServiceProtocol.h
//  Pods
//
//  Created by annidyfeng on 2019/5/2.
//

#ifndef TDataProviderServiceProtocol_h
#define TDataProviderServiceProtocol_h

#import "TCServiceProtocol.h"
@import UIKit;

@class TIMUserProfile;
@protocol TDataProviderServiceProtocol <TCServiceProtocol>

#pragma mark - TIMUserProfile

- (NSString *)getName:(TIMUserProfile *)profile;

- (NSString *)getGender:(TIMUserProfile *)profile;

- (NSString *)getSignature:(TIMUserProfile *)profile;

- (NSString *)getLocation:(TIMUserProfile *)profile;

- (NSDate *)getBirthday:(TIMUserProfile *)profile;

- (NSString *)getAllowType:(TIMUserProfile *)profile;

- (UIImageView *)getAvatarView:(TIMUserProfile *)profile;

@end

#endif /* TDataProviderServiceProtocol_h */
