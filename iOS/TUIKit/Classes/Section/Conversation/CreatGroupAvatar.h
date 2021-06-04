//
//  CreatGroupAvatar.h
//  THeadImgs
//
//  Created by ITD on 2017/3/25.
//  Copyright © 2017年 ITD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreatGroupAvatar : NSObject

/**
 * 根据群 id 实时获取最新的群头像，头像跟新后会缓存在本地，该接口会请求网络
 * 该接口不会读取缓存，如果需要读取缓存，请使用 getCacheGroupAvatar:imageCallback 或者 getCacheAvatarForGroup: number:
 *
 * @param groupID 群ID
 * @param placeholder 占位头像，当网络异常获取失败时，callback 回调会返回该占位头像
 * @param callback 回调
 */
+ (void)fetchGroupAvatars:(NSString *)groupID placeholder:(UIImage *)placeholder callback:(void(^)(BOOL success, UIImage *image, NSString *groupID))callback;

/**
 * 根据给定的url数组创建群组头像
 *
 * @param group 群组成员的头像 url 列表
 * @param finished 创建完成后的回调
 */
+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(UIImage *groupAvatar))finished;

/**
 * 缓存头像
 *
 * @param avatar 准备缓存的图像
 * @param memberNum  当前头像对应的成员数
 * @param groupID 当前缓存的群组ID
 */
+ (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum groupID:(NSString *)groupID;

/**
 * 异步获取头像缓存，该接口会请求接口获取当前群成员个数，并返回对应本地缓存的头像
 *
 * @param groupID 群ID
 * @param imageCallBack 回调
 */
+ (void)getCacheGroupAvatar:(NSString *)groupID callback:(void(^)(UIImage *))imageCallBack;

/**
 * 同步获取头像缓存，该接口不请求网络
 *
 * @param groupId 群组ID
 * @param memberNum 指定群成员个数
 */
+ (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum;

@end
