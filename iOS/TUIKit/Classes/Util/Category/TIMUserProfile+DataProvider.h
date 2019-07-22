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
