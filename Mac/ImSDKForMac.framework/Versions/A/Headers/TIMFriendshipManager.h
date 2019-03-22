//
//  TIMFriendshipManager.h
//  imsdk
//
//  Created by annidyfeng on 2019/3/7.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#ifndef TIMFriendshipManager_h
#define TIMFriendshipManager_h

#import "TIMComm.h"
#import "TIMFriendshipDefine.h"

@interface TIMFriendshipManager : NSObject
/**
 *  获取好友管理器实例
 *
 *  @return 管理器实例
 */
+ (TIMFriendshipManager*)sharedInstance;

/**
 *  设置自己的资料
 *
 *  @param values    需要更新的属性，可一次更新多个字段
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)modifySelfProfile:(NSDictionary<NSString *, id> *)values succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取自己的资料
 *
 *  @param succ  成功回调，返回 TIMUserProfile
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)getSelfProfile:(TIMGetProfileSucc)succ fail:(TIMFail)fail;

/**
 *  获取指定好友资料
 *
 *  @param users 用户id
 *  @prarm forceUpdate 强制从后台拉取
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)getUsersProfile:(NSArray<NSString *> *)users forceUpdate:(BOOL)forceUpdate succ:(TIMGetProfileArraySucc)succ fail:(TIMFail)fail;

@end

#endif /* TIMFriendshipManager_h */
