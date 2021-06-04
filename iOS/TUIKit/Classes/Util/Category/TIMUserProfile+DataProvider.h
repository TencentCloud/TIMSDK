//
//  TIMUserProfile+DataProvider.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/2.
//

#import "THeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface V2TIMUserFullInfo (DataProvider)

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
