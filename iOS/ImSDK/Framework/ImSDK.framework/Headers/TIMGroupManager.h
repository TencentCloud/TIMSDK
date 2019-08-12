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
#import "TIMComm+Group.h"

@interface TIMGroupManager : NSObject

#pragma mark 一，获取群组实例
/////////////////////////////////////////////////////////////////////////////////
//
//                      （一）获取群组实例
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 获取群组实例
/// @{
/**
 *  1.1 获取群管理器实例
 *
 *  @return 管理器实例
 */
+ (TIMGroupManager*)sharedInstance;

///@}

#pragma mark 二，创建/删除/加入/退出群组
/////////////////////////////////////////////////////////////////////////////////
//
//                      （二）创建/删除/加入/退出群组
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 创建/删除/加入/退出群组
/// @{

/**
 *  1.1 创建私有群
 *
 *  快速创建私有群，创建者默认加入群组，无需显式指定，群组类型形态请参考官网文档 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createPrivateGroup:(NSArray<NSString *>*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  1.2 创建公开群
 *
 *  快速创建公开群，创建者默认加入群组，无需显式指定，群组类型形态请参考官网文档 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createPublicGroup:(NSArray<NSString *>*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  1.3 创建聊天室
 *
 *  快速创建聊天室，创建者默认加入群组，无需显式指定，群组类型形态请参考官网文档 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createChatRoomGroup:(NSArray<NSString *>*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  1.4 创建音视频聊天室
 *
 *  快速创建音视频聊天室，创建者默认加入群组，无需显式指定，群组类型形态请参考官网文档 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)
 *
 *  @param groupName 群名
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createAVChatRoomGroup:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  1.5 创建指定类型和 ID 的群组
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
 *  1.6 创建自定义群组
 *
 *  在创建群组时，除了设置默认的成员以及群名外，还可以设置如群公告、群简介等字段。
 *
 *  @param groupInfo 群组信息，详情请参考 TIMComm+Group.h 里面的 TIMCreateGroupInfo 定义
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createGroup:(TIMCreateGroupInfo*)groupInfo succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  1.7 解散群组
 *
 *  1. 私有群：任何人都无法解散群组
 *  2. 公开群、聊天室、直播大群：群主可以解散群组。
 *
 *  @param groupId 群组Id
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)deleteGroup:(NSString*)groupId succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  1.8 申请加群
 *
 *  1. 私有群：不能由用户主动申请入群。
 *  2. 公开群、聊天室：可以主动申请进入。
 *  3. 直播大群：可以任意加入群组。
 *  4. 如果群组设置为需要审核，申请入群后管理员和群主会收到申请入群系统消息 TIMGroupSystemElem，判断 TIMGroupSystemElem 的 Type 类型如果是 TIM_GROUP_SYSTEM_ADD_GROUP_REQUEST_TYPE ，调用消息的 accept 接口同意入群，申请人会收到同意入群的消息 TIMGroupSystemElem（Type：TIM_GROUP_SYSTEM_ADD_GROUP_ACCEPT_TYPE），调用 refuse 接口拒绝入群，申请人会收到拒绝入群的消息 TIMGroupSystemElem（Type：TIM_GROUP_SYSTEM_ADD_GROUP_REFUSE_TYPE）。
 *  5. 如果群主设置为任何人可加入，则直接入群成功。
 *
 *  @param groupId 申请加入的群组Id
 *  @param msg   申请消息
 *  @param succ  成功回调（申请成功等待审批）
 *  @param fail  失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)joinGroup:(NSString*)groupId msg:(NSString*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  1.9 主动退出群组
 *
 *  1. 私有群：全员可退出群组。
 *  2. 公开群、聊天室、直播大群：群主不能退出。
 *  3. 当用户主动退出群组时，该用户会收到退群消息 TIMGroupSystemElem（Type：TIM_GROUP_SYSTEM_QUIT_GROUP_TYPE），只有退群的用户自己可以收到。当用户调用 QuitGroup 时成功回调返回，表示已退出成功，此消息主要为了多终端同步，其他终端可以作为更新群列表的时机，本终端可以选择忽略。
 *
 *  @param groupId 群组Id
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)quitGroup:(NSString*)groupId succ:(TIMSucc)succ fail:(TIMFail)fail;


///@}

#pragma mark 三，邀请/删除群成员
/////////////////////////////////////////////////////////////////////////////////
//
//                      （三）邀请/删除群成员
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 邀请/删除群成员
/// @{

/**
 *  3.1 邀请好友入群
 *
 *  1. 只有私有群可以邀请用户入群
 *  2. 公开群，聊天室不能邀请用户入群，但在创建群时可以直接拉人入群
 *  3. 音视频聊天室不能拉用户入群，也不能在创建群时拉人入群，只能用户主动进群
 *
 *  @param groupId 群组Id
 *  @param members 要加入的成员列表（NSString* 类型数组）
 *  @param succ    成功回调 (TIMGroupMemberResult 列表)
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)inviteGroupMember:(NSString*)groupId members:(NSArray<NSString *>*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  3.2 删除群成员
 *
 *  1. 私有群：只有创建者可删除群组成员。
 *  2. 公开群、聊天室：只有管理员和群主可以踢人。
 *  3. 对于直播大群：不能踢人。
 *
 *  @param groupId 群组Id
 *  @param reason  删除原因
 *  @param members 要删除的成员列表
 *  @param succ    成功回调 (TIMGroupMemberResult 列表)
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)deleteGroupMemberWithReason:(NSString*)groupId reason:(NSString*)reason members:(NSArray<NSString *>*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

///@}

#pragma mark 四，获取群信息
/////////////////////////////////////////////////////////////////////////////////
//
//                      （四）获取群信息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 获取群信息
/// @{

/**
 *  4.1 获取群列表
 *
 *  获取自己所加入的群列表。
 *
 *  @param succ 成功回调，NSArray 列表为 TIMGroupInfo，结构体只包含 group|groupName|groupType|faceUrl|allShutup|selfInfo 信息
 *  @param fail 失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupList:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  4.2 获取服务器存储的群组信息
 *
 *  1. 无论是公开群还是私有群，群成员均可以拉到群组信息。
 *  2. 如果是公开群，非群组成员可以拉到 group|groupName|owner|groupType|createTime|maxMemberNum|memberNum|introduction|faceURL|addOpt|onlineMemberNum|customInfo 这些字段信息。如果是私有群，非群组成员拉取不到群组信息。
 *  3. 默认拉取基本资料,如果想要拉取自定义字段，首先要通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群维度自定义字段 配置对应的 "自定义字段" 和用户操作权限，然后设置 TIMUserConfig -> IMGroupInfoOption -> groupCustom = @[@"自定义字段名称",...]。

 *  @param succ 成功回调，不包含 selfInfo 信息
 *  @param fail 失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupInfo:(NSArray*)groups succ:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  4.3 获取本地存储的群组信息
 *
 *  1. 无论是公开群还是私有群，群成员均可以拉到群组信息。
 *  2. 如果是公开群，非群组成员可以拉到 group|groupName|owner|groupType|createTime|maxMemberNum|memberNum|introduction|faceURL|addOpt|onlineMemberNum|customInfo 这些字段信息。如果是私有群，非群组成员拉取不到群组信息。
 *
 *  @param groupId 群组Id
 *
 *  @return 群组信息
 */
- (TIMGroupInfo *)queryGroupInfo:(NSString *)groupId;

/**
 *  4.4 获取群成员列表
 *
 *  默认拉取内置字段，但不拉取自定义字段，如果想要拉取自定义字段，首先要通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群成员维度自定义字段配置对应的 "自定义字段" 和用户操作权限，后设置 TIMUserConfig -> TIMGroupMemberInfoOption -> memberCustom = @[@"自定义字段名称",...]
 *
 *  @param groupId 群组Id
 *  @param succ    成功回调 (TIMGroupMemberInfo 列表)
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupMembers:(NSString*)groupId succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  4.5 获取本人在群组内的成员信息
 *
 *  默认拉取基本资料，如果想要拉取自定义字段，请参考 getGroupMembers
 *
 *  @param groupId 群组Id
 *  @param succ    成功回调，返回信息
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupSelfInfo:(NSString*)groupId succ:(TIMGroupSelfSucc)succ fail:(TIMFail)fail;

/**
 *  4.6 获取群组指定成员的信息
 *
 *  获取群组指定成员的信息，需要设置群成员 members，其他限制参考 getGroupMembers
 *
 *  @param groupId 群组Id
 *  @param members 成员Id（NSString*）列表
 *  @param succ    成功回调 (TIMGroupMemberInfo 列表)
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupMembersInfo:(NSString*)groupId members:(NSArray<NSString *>*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  4.7 获取指定类型的成员列表（支持按字段拉取，分页）
 *
 *  @param groupId    群组Id
 *  @param filter     群成员角色过滤方式
 *  @param flags      拉取资料标志
 *  @param custom     要获取的自定义key（NSString*）列表
 *  @param nextSeq    分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0
 *  @param succ       成功回调
 *  @param fail       失败回调
 *  @return 0：成功；1：失败
 */
- (int)getGroupMembers:(NSString*)groupId ByFilter:(TIMGroupMemberFilter)filter flags:(TIMGetGroupMemInfoFlag)flags custom:(NSArray<NSString *>*)custom nextSeq:(uint64_t)nextSeq succ:(TIMGroupMemberSuccV2)succ fail:(TIMFail)fail;

/**
 *  4.8 获取接受消息选项
 *
 *  @param groupId  群组Id
 *  @param succ     成功回调, TIMGroupReceiveMessageOpt 0：接收消息；1：不接收消息，服务器不进行转发；2：接受消息，不进行 iOS APNs 推送
 *  @param fail     失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getReciveMessageOpt:(NSString*)groupId succ:(TIMGroupReciveMessageOptSucc)succ fail:(TIMFail)fail;

///@}

#pragma mark 五，修改群信息
/////////////////////////////////////////////////////////////////////////////////
//
//                      （五）修改群信息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 修改群信息
/// @{

/**
 *  5.1 修改群名
 *
 *  1. 公开群、聊天室和直播大群：只有群主或者管理员可以修改群名。
 *  2. 私有群：任何人可修改群名。
 *
 *  @param groupId   群组Id
 *  @param groupName 新群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupName:(NSString*)groupId groupName:(NSString*)groupName succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.2 修改群简介
 *
 *  1. 公开群、聊天室、直播大群：只有群主或者管理员可以修改群简介。
 *  2. 私有群：任何人可修改群简介。
 *
 *  @param groupId          群组Id
 *  @param introduction     群简介（最长120字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupIntroduction:(NSString*)groupId introduction:(NSString*)introduction succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.3 修改群公告
 *
 *  1. 公开群、聊天室、直播大群：只有群主或者管理员可以修改群公告。
 *  2. 私有群：任何人可修改群公告。
 *
 *  @param groupId          群组Id
 *  @param notification     群公告（最长150字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupNotification:(NSString*)groupId notification:(NSString*)notification succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.4 修改群头像
 *
 *  1. 公开群、聊天室、直播大群：只有群主或者管理员可以修改群头像。
 *  2. 私有群：任何人可修改群头像。
 *
 *  @param groupId          群组Id
 *  @param url              群头像地址（最长100字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupFaceUrl:(NSString*)groupId url:(NSString*)url succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.5 修改加群选项
 *
 *  1. 公开群、聊天室、直播大群：只有群主或者管理员可以修改加群选项。
 *  2. 私有群：只能通过邀请加入群组，不能主动申请加入某个群组。
 *
 *  @param groupId          群组Id
 *  @param opt              加群选项，详见 TIMGroupAddOpt
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupAddOpt:(NSString*)groupId opt:(TIMGroupAddOpt)opt succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.6 修改群组是否可被搜索属性
 *
 *  @param groupId    群组Id
 *  @param searchable 是否能被搜索
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupSearchable:(NSString*)groupId searchable:(BOOL)searchable succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.7 修改接受消息选项
 *
 *  默认情况下，公开群和私有群是接收并离线推送群消息，聊天室和直播大群是接收但不离线推送群消息。
 *
 *  @param groupId          群组Id
 *  @param opt              接受消息选项，详见 TIMGroupReceiveMessageOpt
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyReceiveMessageOpt:(NSString*)groupId opt:(TIMGroupReceiveMessageOpt)opt succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.8 修改群组全员禁言属性
 *
 *  1. 群主、管理员：有权限进行全员禁言的操作。
 *  2. 所有群组类型：都支持全员禁言的操作。
 *
 *  @param groupId 群组Id
 *  @param shutup  是否禁言
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupAllShutup:(NSString*)groupId shutup:(BOOL)shutup succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.9 修改群自定义字段集合
 *
 *  通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群维度自定义字段 配置相关的 key 和权限。
 *
 *  @param groupId    群组Id
 *  @param customInfo 自定义字段集合,key 是 NSString* 类型,value 是 NSData* 类型
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupCustomInfo:(NSString*)groupId customInfo:(NSDictionary<NSString *,NSData *>*)customInfo succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  5.10 转让群给新群主
 *
 *  1. 只有群主才有权限进行群转让操作。
 *  2. 直播大群不能进行群转让操作。
 *
 *  @param groupId    群组Id
 *  @param identifier 新的群主Id
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupOwner:(NSString*)groupId user:(NSString*)identifier succ:(TIMSucc)succ fail:(TIMFail)fail;

///@}

#pragma mark 六，修改群成员信息
/////////////////////////////////////////////////////////////////////////////////
//
//                      （六）修改群成员信息
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 修改群成员信息
/// @{

/**
 *  6.1 修改群成员名片
 *
 *  只有本人、管理员或群主能够调用
 *
 *  @param groupId          群组Id
 *  @param identifier       被操作用户identifier
 *  @param nameCard         群名片
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberInfoSetNameCard:(NSString*)groupId user:(NSString*)identifier nameCard:(NSString*)nameCard succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  6.2 修改群成员角色
 *
 *  1. 群主、管理员：可以进行对群成员的身份进行修改。
 *  2. 直播大群：不支持修改用户群内身份。
 *
 *  @param groupId          群组Id
 *  @param identifier       被修改角色的用户identifier
 *  @param role             角色（注意：不能修改为群主），详见 TIMGroupMemberRole
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberInfoSetRole:(NSString*)groupId user:(NSString*)identifier role:(TIMGroupMemberRole)role succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  6.3 修改群组成员是否可见属性
 *
 *  @param groupId 群组Id
 *  @param visible 是否可见
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberVisible:(NSString*)groupId visible:(BOOL)visible succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  6.4 禁言用户
 *
 *  只有管理员或群主能够调用
 *
 *  @param groupId          群组Id
 *  @param identifier       被禁言的用户identifier
 *  @param stime            禁言时间
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberInfoSetSilence:(NSString*)groupId user:(NSString*)identifier stime:(uint32_t)stime succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  6.5 修改群成员自定义字段集合
 *
 *  通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群成员维度自定义字段 配置相关的 key 和权限。
 *
 *  @param groupId    群组 Id
 *  @param identifier 被操作用户 identifier
 *  @param customInfo 自定义字段集合,key 是 NSString* 类型,value 是 NSData* 类型
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberInfoSetCustomInfo:(NSString*)groupId user:(NSString*)identifier customInfo:(NSDictionary<NSString*,NSData*> *)customInfo succ:(TIMSucc)succ fail:(TIMFail)fail;

///@}

#pragma mark 七，群未决逻辑
/////////////////////////////////////////////////////////////////////////////////
//
//                      （七）群未处理请求逻辑
//
/////////////////////////////////////////////////////////////////////////////////
/// @name 群未处理请求逻辑
/// @{

/**
 *  7.1 获取群组未处理请求列表
 *
 *  1. 群未处理请求泛指所有需要审批的群相关的操作（例如：加群待审批，拉人入群待审批等等）。即便审核通过或者拒绝后，该条信息也可通过此接口拉回，拉回的信息中有已处理标志
 *  2. 审批人：有权限拉取相关信息,如果 UserA 申请加入群 GroupA，则群管理员可获取此未处理相关信息，UserA 因为没有审批权限，不需要拉取未处理信息。如果 AdminA 拉 UserA 进去 GroupA，则 UserA 可以拉取此未处理相关信息，因为该未处理信息待 UserA 审批。
 *
 *  @param option 拉取群未处理请求参数配置，详情请参考 TIMComm.h -> TIMGroupPendencyOption
 *  @param succ   成功回调，返回未决列表
 *  @param fail   失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getPendencyFromServer:(TIMGroupPendencyOption*)option succ:(TIMGetGroupPendencyListSucc)succ fail:(TIMFail)fail;

/**
 *  7.2 群未处理列表已读上报
 *
 *  对于未处理信息，SDK 可对其和之前的所有未处理请求上报已读。上报已读后，仍然可以拉取到这些未决信息，但可通过对已读时戳的判断判定未决信息是否已读。
 *
 *  @param timestamp 上报已读时间戳
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)pendencyReport:(uint64_t)timestamp succ:(TIMSucc)succ fail:(TIMFail)fail;

///@}

@end
#endif
