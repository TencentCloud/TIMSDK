/******************************************************************************
 *
 *  本文件声明了用于获取用户信息的协议
 *  实现了本协议的类，便可以根据传入的信息获取用户的姓名、签名、生日、添加方式、头像等用户信息。
 *
 ******************************************************************************/

#ifndef TUIUserProfileDataProviderServiceProtocol_h
#define TUIUserProfileDataProviderServiceProtocol_h

#import "TCServiceProtocol.h"
@import UIKit;

@class V2TIMUserFullInfo;
@protocol TUIUserProfileDataProviderServiceProtocol <TCServiceProtocol>

#pragma mark - TIMUserProfile

/**
 *  获取用户姓名。
 *  如果当前信息对应的用户是好友的话，则通过 TIMFriendshipManager 提供的 queryFriend 接口获取好友，并进一步获取备注。
 *  如果当前信息对应的用户不是好友，则返回传入信息中的用户 ID。
 *
 *  @return 返回的用户昵称。好友默认返回备注，当好友未设置备注或者为陌生人时返回用户 ID。
 */
- (NSString *)getName:(V2TIMUserFullInfo *)profile;

/**
 *  获取用户的性别。
 *
 *  @param profile 传入的用户资料。从该资料中获取特定的信息。
 *
 *  @return 以字符串形式返回用户性别。“男”/“女”/“未知”。
 */
- (NSString *)getGender:(V2TIMUserFullInfo *)profile;

/**
 *  获取用户签名。
 *
 *  @param profile 传入的用户资料。从该资料中获取特定的信息。
 *
 *  @return 以字符串形式返回用户签名。
 */
- (NSString *)getSignature:(V2TIMUserFullInfo *)profile;

/**
 *  获取用户的添加要求。用于在用户信息页面显示。
 *
 *  @param profile 传入的用户资料。从该资料中获取特定的信息。
 *
 *  @return 以字符串形式返回。 "同意任何用户加好友" / "需要验证" / "需要验证"。
 */
- (NSString *)getAllowType:(V2TIMUserFullInfo *)profile;


/**
 *  获取用户头像
 *  profile 中含有用户头像的 URL，我们通过 URL 获取头像并包装为 UIImageView 后返回。
 *
 *  @param profile 传入的用户资料。从该资料中获取特定的信息。
 *
 *  @return 将获取到的图像包装为 UIImageView 后返回。
 */
- (UIImageView *)getAvatarView:(V2TIMUserFullInfo *)profile;

@end

#endif /* TUIUserProfileDataProviderServiceProtocol_h */
