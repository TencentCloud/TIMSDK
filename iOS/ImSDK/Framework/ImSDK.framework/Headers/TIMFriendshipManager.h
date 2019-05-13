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
 *  @param values 需要更新的属性，可一次更新多个字段. 参见 TIMFriendshipDefine.h 的 TIMProfileTypeKey_XXX
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
 *  在缓存中查询自己的资料
 *
 *  @return 返回缓存的资料，未找到返回nil
 */
- (TIMUserProfile *)querySelfProfile;

/**
 *  获取指定用户资料
 *
 *  @param identifiers 用户id，非好友的用户也可以
 *  @prarm forceUpdate 强制从后台拉取
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)getUsersProfile:(NSArray<NSString *> *)identifiers forceUpdate:(BOOL)forceUpdate succ:(TIMUserProfileArraySucc)succ fail:(TIMFail)fail;

/**
 *  在缓存中查询的资料
 *
 *  @praram identifier 用户id，非好友的用户也可以
 *
 *  @return 返回缓存的资料，未找到返回nil
 */
- (TIMUserProfile *)queryUserProfile:(NSString *)identifier;

/**
 *  获取好友列表
 *
 *  @param succ 成功回调，返回好友(TIMFriend)列表
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
-(int)getFriendList:(TIMFriendArraySucc)succ fail:(TIMFail)fail;


/**
 *  添加好友
 *
 *  @param request 添加好友请求
 *  @param succ  成功回调(TIMFriendResult)
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)addFriend:(TIMFriendRequest *)request succ:(TIMFriendResultSucc)succ fail:(TIMFail)fail;

/**
 *  响应对方好友邀请
 *
 *  @param response  响应请求
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)doResponse:(TIMFriendResponse *)response succ:(TIMFriendResultSucc)succ fail:(TIMFail)fail;

/**
 *  删除好友
 *
 *  @param identifiers 好友id
 *  @param delType 删除类型（单向好友、双向好友）
 *  @param succ  成功回调([TIMFriendResult])
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)deleteFriends:(NSArray *)identifiers delType:(TIMDelFriendType)delType succ:(TIMFriendResultArraySucc)succ fail:(TIMFail)fail;

/**
 *  修改好友
 *
 *  @param identifier 好友id
 *  @param values  需要更新的属性，可一次更新多个字段. 参见 TIMFriendshipDefine.h 的 TIMFriendTypeKey_XXX
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)modifyFriend:(NSString *)identifier values:(NSDictionary<NSString *, id> *)values succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取未决列表
 *
 *  @param pendencyRequest  请求信息，详细参考TIMFriendPendencyRequest
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)getPendencyList:(TIMFriendPendencyRequest *)pendencyRequest succ:(TIMGetFriendPendencyListSucc)succ fail:(TIMFail)fail;

/**
 *  未决删除
 *
 *  @param type  未决好友类型
 *  @param identifiers 要删除的未决列表
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)deletePendency:(TIMPendencyType)type users:(NSArray *)identifiers succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  未决已读上报
 *
 *  @param timestamp 已读时间戳，此时间戳以前的消息都将置为已读
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)pendencyReport:(uint64_t)timestamp succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取黑名单列表
 *
 *  @param succ 成功回调，返回NSString*列表
 *  @param fail 失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)getBlackList:(TIMFriendArraySucc)succ fail:(TIMFail)fail;

/**
 *  添加用户到黑名单
 *
 *  @param identifiers 用户列表
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)addBlackList:(NSArray *)identifiers succ:(TIMFriendResultArraySucc)succ fail:(TIMFail)fail;

/**
 *  把用户从黑名单中删除
 *
 *  @param identifiers 用户列表
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)deleteBlackList:(NSArray *)identifiers succ:(TIMFriendResultArraySucc)succ fail:(TIMFail)fail;

/**
 *  新建好友分组
 *
 *  @param groupNames  分组名称列表,必须是当前不存在的分组
 *  @param identifiers 要添加到分组中的好友
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)createFriendGroup:(NSArray *)groupNames users:(NSArray *)identifiers succ:(TIMFriendResultArraySucc)succ fail:(TIMFail)fail;

/**
 *  获取指定的好友分组信息
 *
 *  @param groupNames      要获取信息的好友分组名称列表,传入nil获得所有分组信息
 *  @param succ  成功回调，返回 TIMFriendGroup* 列表
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)getFriendGroups:(NSArray *)groupNames succ:(TIMFriendGroupArraySucc)succ fail:(TIMFail)fail;

/**
 *  删除好友分组
 *
 *  @param groupNames  要删除的好友分组名称列表
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)deleteFriendGroup:(NSArray *)groupNames succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改好友分组的名称
 *
 *  @param oldName   原来的分组名称
 *  @param newName   新的分组名称
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)renameFriendGroup:(NSString*)oldName newName:(NSString*)newName succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  添加好友到一个好友分组
 *
 *  @param groupName   好友分组名称
 *  @param identifiers  要添加到分组中的好友
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)addFriendsToFriendGroup:(NSString *)groupName users:(NSArray *)identifiers succ:(TIMFriendResultArraySucc)succ fail:(TIMFail)fail;

/**
 *  从好友分组中删除好友
 *
 *  @param groupName   好友分组名称
 *  @param identifiers  要移出分组的好友
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 发送请求成功
 */
- (int)deleteFriendsFromFriendGroup:(NSString *)groupName users:(NSArray *)identifiers succ:(TIMFriendResultArraySucc)succ fail:(TIMFail)fail;
@end

#endif /* TIMFriendshipManager_h */
