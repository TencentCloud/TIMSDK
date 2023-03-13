#import <Foundation/Foundation.h>
@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

@interface V2TIMGroupInfo(TUIDataProvider)

- (BOOL)isMeOwner;
- (BOOL)isPrivate;
- (BOOL)canInviteMember;
- (BOOL)canRemoveMember;
- (BOOL)canDismissGroup;
- (BOOL)canSupportSetAdmain;

@end

NS_ASSUME_NONNULL_END
