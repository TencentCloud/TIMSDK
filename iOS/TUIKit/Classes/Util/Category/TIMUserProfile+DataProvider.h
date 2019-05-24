//
//  TIMUserProfile+DataProvider.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/2.
//

#import <ImSDK/ImSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIMUserProfile (DataProvider)

- (NSString *)showName;

- (NSString *)showGender;

- (NSString *)showSignature;

- (NSString *)showLocation;

- (NSDate *)showBirthday;

- (NSString *)showAllowType;

- (void)setShowBirthday:(NSDate *)date;

- (UIImageView *)avatarView;

@end

NS_ASSUME_NONNULL_END
