//
//  TCommonCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIDarkModel.h"

@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN
/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIUserFullInfo
//
/////////////////////////////////////////////////////////////////////////////////
@interface V2TIMUserFullInfo (TUIUserFullInfo)
- (NSString *)showName;
- (NSString *)showGender;
- (NSString *)showSignature;
- (NSString *)showAllowType;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIUserModel
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIUserModel : NSObject <NSCopying>
@property(nonatomic, copy) NSString *userId;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *avatar;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIScrollView
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIScrollView : UIScrollView
@property(strong, nonatomic) UIImageView *imageView;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIGroupAvatar
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIGroupAvatar : NSObject

/**
 * 根据群 id 实时获取最新的群头像，头像更新后会缓存在本地，该接口会请求网络
 * 该接口不会读取缓存，如果需要读取缓存，请使用 getCacheGroupAvatar:imageCallback 或者 getCacheAvatarForGroup: number:
 *
 * Obtain the latest group avatar in real time according to the group id. After the avatar is updated, it will be cached locally. This interface will request
 * the network This interface will not use the cache. If you need to read the cache, please use getCacheGroupAvatar:imageCallback or getCacheAvatarForGroup:
 * number:
 */
+ (void)fetchGroupAvatars:(NSString *)groupID placeholder:(UIImage *)placeholder callback:(void (^)(BOOL success, UIImage *image, NSString *groupID))callback;

/**
 * 根据给定的url数组创建群组头像
 * Create a group avatar based on the given url array
 */
+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(UIImage *groupAvatar))finished;

/**
 * 根据群组 ID 和群组成员，缓存头像
 * Cache avatars based on group ID and number of group members
 */
+ (void)cacheGroupAvatar:(UIImage *)avatar number:(UInt32)memberNum groupID:(NSString *)groupID;

/**
 * 异步获取头像缓存，该接口会请求接口获取当前群成员个数，并返回对应本地缓存的头像
 * Get the cached avatar asynchronously, this interface will request the interface to get the current number of group members, and return the avatar
 * corresponding to the local cache
 */
+ (void)getCacheGroupAvatar:(NSString *)groupID callback:(void (^)(UIImage *, NSString *groupID))imageCallBack;

/**
 * 同步获取头像缓存，该接口不请求网络
 * Get the cached avatar synchronously, this interface does not request the network
 */
+ (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum;

/**
 * 清理指定群组的头像缓存
 * Clear the avatar cache of the specified group
 */
+ (void)asyncClearCacheAvatarForGroup:(NSString *)groupID;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                          TUIImageCache
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIImageCache : NSObject

+ (instancetype)sharedInstance;

- (void)addResourceToCache:(NSString *)path;
- (UIImage *)getResourceFromCache:(NSString *)path;

- (void)addFaceToCache:(NSString *)path;
- (UIImage *)getFaceFromCache:(NSString *)path;

@end
/////////////////////////////////////////////////////////////////////////////////
//
//                          TUINavigationController
//
/////////////////////////////////////////////////////////////////////////////////
@class TUINavigationController;
@protocol TUINavigationControllerDelegate <NSObject>
@optional
- (void)navigationControllerDidClickLeftButton:(TUINavigationController *)controller;
- (void)navigationControllerDidSideSlideReturn:(TUINavigationController *)controller fromViewController:(UIViewController *)fromViewController;
@end

@interface TUINavigationController : UINavigationController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property(nonatomic, weak) UIViewController *currentShowVC;
@property(nonatomic, weak) id<TUINavigationControllerDelegate> uiNaviDelegate;
@property(nonatomic, strong) UIImage *navigationItemBackArrowImage;
@end

@interface UIAlertController (TUITheme)

- (void)tuitheme_addAction:(UIAlertAction *)action;

@end

typedef void (^TUIValueCallbck)(NSDictionary *param);
typedef void (^TUINonValueCallbck)(void);

typedef NSString *TUIExtVauleType;

@interface NSObject (TUIExtValue)

@property(nonatomic, copy) TUIValueCallbck tui_valueCallback;

@property(nonatomic, copy) TUINonValueCallbck tui_nonValueCallback;

@property(nonatomic, strong) id tui_extValueObj;

@end

NS_ASSUME_NONNULL_END
