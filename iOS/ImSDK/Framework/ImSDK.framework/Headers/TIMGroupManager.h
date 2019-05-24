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
 *  1. 默认创建群组时，IM 通讯云服务器会生成一个唯一的 ID，该 ID 将以 @TGS# 开头，且保证在 App 中唯一，以便后续操作。
 *  2. 如果用户需要自定义群组 ID，在创建时可指定 ID，自定义群组 ID 必须为可打印 ASCII 字符（0x20-0x7e），最长 48 个字节，且前缀不能为 @TGS#（避免与默认分配的群组 ID 混淆）
 *
 *  @param type       群类型,Private,Public,ChatRoom,AVChatRoom
 *  @param groupId    自定义群组 ID，为空时系统自动分配
 *  @param groupName  群组名称
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createGroup:(NSString*)type groupId:(NSString*)groupId groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  解散群组
 *
 *  1. 私有群：任何人都无法解散群组
 *  2. 公开群、聊天室、直播大群：群主可以解散群组。
 *
 *  @param group 群组Id
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)deleteGroup:(NSString*)group succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  申请加群
 *
 *  1. 私有群：不能由用户主动申请入群。
 *  2. 公开群、聊天室：可以主动申请进入。
 *  3. 直播大群：可以任意加入群组。
 *  4. 如果群组设置为需要审核，申请入群后管理员和群主会收到申请入群系统消息 TIMGroupSystemElem，判断 TIMGroupSystemElem 的 Type 类型如果是 TIM_GROUP_SYSTEM_ADD_GROUP_REQUEST_TYPE ，调用消息的 accept 接口同意入群，申请人会收到同意入群的消息 TIMGroupSystemElem（Type：TIM_GROUP_SYSTEM_ADD_GROUP_ACCEPT_TYPE），调用 refuse 接口拒绝入群，申请人会收到拒绝入群的消息 TIMGroupSystemElem（Type：TIM_GROUP_SYSTEM_ADD_GROUP_REFUSE_TYPE）。
 *  5. 如果群主设置为任何人可加入，则直接入群成功。
 *
 *  @param group 申请加入的群组Id
 *  @param msg   申请消息
 *  @param succ  成功回调（申请成功等待审批）
 *  @param fail  失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)joinGroup:(NSString*)group msg:(NSString*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  主动退出群组
 *
 *  1. 私有群：全员可退出群组。
 *  2. 公开群、聊天室、直播大群：群主不能退出。
 *  3. 当用户主动退出群组时，该用户会收到退群消息 TIMGroupSystemElem（Type：TIM_GROUP_SYSTEM_QUIT_GROUP_TYPE），只有退群的用户自己可以收到。当用户调用 QuitGroup 时成功回调返回，表示已退出成功，此消息主要为了多终端同步，其他终端可以作为更新群列表的时机，本终端可以选择忽略。
 *
 *  @param group 群组Id
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)quitGroup:(NSString*)group succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

#endif
