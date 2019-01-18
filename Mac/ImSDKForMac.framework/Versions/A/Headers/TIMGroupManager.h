//
//  TIMGroupManager.h
//  ImSDK
//
//  Created by bodeng on 17/3/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMGroupManager_h
#define ImSDK_TIMGroupManager_h

#import "TIMComm.h"


@interface TIMGroupManager : NSObject

/**
 *  获取群管理器实例
 *
 *  @return 管理器实例
 */
+ (TIMGroupManager*)sharedInstance;

/**
 *  创建群组
 *
 *  @param type       群类型,Private,Public,ChatRoom,AVChatRoom
 *  @param groupId    自定义群组id，为空时系统自动分配
 *  @param groupName  群组名称
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0 成功
 */
- (int)createGroup:(NSString*)type groupId:(NSString*)groupId groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  解散群组
 *
 *  @param group 群组Id
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
- (int)deleteGroup:(NSString*)group succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  申请加群
 *
 *  @param group 申请加入的群组Id
 *  @param msg   申请消息
 *  @param succ  成功回调（申请成功等待审批）
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
- (int)joinGroup:(NSString*)group msg:(NSString*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  主动退出群组
 *
 *  @param group 群组Id
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
- (int)quitGroup:(NSString*)group succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

#endif
