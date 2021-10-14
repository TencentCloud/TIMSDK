#import <Foundation/Foundation.h>
@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

@interface V2TIMGroupInfo(TUIDataProvider)


/**
 *  判断当前群是否是私有群。
 *
 *  @return YES：是私有群；NO：不是私有群
 */
-(BOOL) isPrivate;


/**
 *  判断当前用户在当前群能否邀请成员。
 *
 *  @return YES：能邀请；NO：不能邀请
 */
-(BOOL) canInviteMember;

/**
 *  判断当前用户在当前群能否踢出群成员。
 *
 *  @return YES：能踢出；NO：不能踢出
 */
-(BOOL) canRemoveMember;

/**
 *  判断当前用户能否删除（解散）当前群组。
 *
 *  @return YES：能删除；NO：不能删除
 */
-(BOOL) canDelete;


@end

NS_ASSUME_NONNULL_END
