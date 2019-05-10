//
//  TIMGroupManager+Ext.h
//  IMGroupExt
//
//  Created by tomzhu on 2017/2/9.
//
//

#ifndef TIMGroupManager_Ext_h
#define TIMGroupManager_Ext_h

#import "TIMGroupManager.h"
#import "TIMComm+Group.h"

@interface TIMGroupManager (Ext)

/**
 *  创建私有群
 *
 *  创建者默认加入群组，无需显式指定，群组类型形态请参考官网文档 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createPrivateGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建公开群
 *
 *  创建者默认加入群组，无需显式指定，群组类型形态请参考官网文档 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)
 *get
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createPublicGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建聊天室
 *
 *  创建者默认加入群组，无需显式指定，群组类型形态请参考官网文档 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createChatRoomGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建音视频聊天室（可支持超大群，详情可参考wiki文档）
 *
 *  创建者默认加入群组，无需显式指定，群组类型形态请参考官网文档 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)
 *
 *  @param groupName 群名
 *  @param succ      成功回调 groupId
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)createAVChatRoomGroup:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建自定义群组
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
 *  邀请好友入群
 *
 *  1. 只有私有群可以拉用户入群。
 *  2. 直播大群：不能邀请用户入群。
 *  3. 不允许群成员邀请他人入群，但创建群时可以直接拉人入群。
 *
 *  @param group   群组Id
 *  @param members 要加入的成员列表（NSString* 类型数组）
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)inviteGroupMember:(NSString*)group members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  删除群成员
 *
 *  1. 私有群：只有创建者可删除群组成员。
 *  2. 公开群、聊天室：只有管理员和群主可以踢人。
 *  3. 对于直播大群：不能踢人。
 *
 *  @param group   群组Id
 *  @param reason  删除原因
 *  @param members 要删除的成员列表
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)deleteGroupMemberWithReason:(NSString*)group reason:(NSString*)reason members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  获取群公开信息(暂未实现)
 *
 *  任意用户可以获取群公开资料，只能获取公开信息。
 *
 *  @param groups 群组Id
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupPublicInfo:(NSArray*)groups succ:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  获取群列表
 *
 *  1. 可以获取自己所加入的群列表。
 *  2. 只能获得加入的部分直播大群的列表。
 *
 *  @param succ 成功回调，NSArray 列表为 TIMGroupInfo，结构体只包含 group\groupName\groupType\faceUrl\allShutup\selfInfo 信息
 *  @param fail 失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupList:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  获取群信息
 *
 *  1. 获取群组资料接口只能由群成员调用，非群成员无法通过此方法获取资料，需要调用 getGroupPublicInfo 获取资料。
 *  2. 默认拉取基本资料,如果想要拉取自定义字段，首先要通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群维度自定义字段 配置相关的 key 和权限，然后在 initSDK 的时候把生成的 key 设置在 IMGroupInfoOption 里面的 groupCustom 字段。需要注意的是，只有对自定义字段 value 做了赋值或则修改，才能拉取到自定义字段。
 *
 *  @param succ 成功回调，不包含 selfInfo信息
 *  @param fail 失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupInfo:(NSArray*)groups succ:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  获取本人在群组内的成员信息
 *
 *  默认拉取基本资料，如果想要拉取自定义字段，请参考 getGroupInfo
 *
 *  @param group 群组Id
 *  @param succ  成功回调，返回信息
 *  @param fail  失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupSelfInfo:(NSString*)group succ:(TIMGroupSelfSucc)succ fail:(TIMFail)fail;

/**
 *  获取接受消息选项
 *
 *  @param group  群组Id
 *  @param succ   成功回调, TIMGroupReceiveMessageOpt 0：接收消息；1：不接收消息，服务器不进行转发；2：接受消息，不进行 iOS APNs 推送
 *  @param fail   失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getReciveMessageOpt:(NSString*)group succ:(TIMGroupReciveMessageOptSucc)succ fail:(TIMFail)fail;

/**
 *  获取群成员列表
 *
 *  1. 获取群内成员列表，默认拉取内置字段，但不拉取自定义字段，如果想要拉取自定义字段，首先要通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群维度自定义字段 配置相关的 key 和权限，然后在 initSDK 的时候把生成的 key 设置在 IMGroupInfoOption 里面的 groupCustom 字段。需要注意的是，只有对自定义字段的 value 做了赋值或则修改，才能拉取到自定义字段。
 *  2. 任何群组类型：都可以获取成员列表。
 *  3. 直播大群：只能拉取部分成员（包括群主、管理员和部分成员）。
 *
 *  @param group 群组Id
 *  @param succ  成功回调(TIMGroupMemberInfo列表)
 *  @param fail  失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupMembers:(NSString*)group succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  获取群组指定成员的信息
 *
 *  获取群组指定成员的信息，需要设置群成员 members，其他限制参考 getGroupMembers
 *
 *  @param group   群组Id
 *  @param members 成员Id（NSString*）列表
 *  @param succ    成功回调(TIMGroupMemberInfo列表)
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getGroupMembersInfo:(NSString*)group members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  获取指定类型的成员列表（支持按字段拉取，分页）
 *
 *  @param group      群组Id：（NSString*) 列表
 *  @param filter     群成员角色过滤方式
 *  @param flags      拉取资料标志
 *  @param custom     要获取的自定义key（NSString*）列表
 *  @param nextSeq    分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0
 *  @param succ       成功回调
 *  @param fail       失败回调
 *  @return 0：成功；1：失败
 */
- (int)getGroupMembers:(NSString*)group ByFilter:(TIMGroupMemberFilter)filter flags:(TIMGetGroupMemInfoFlag)flags custom:(NSArray*)custom nextSeq:(uint64_t)nextSeq succ:(TIMGroupMemberSuccV2)succ fail:(TIMFail)fail;

/**
 *  修改群名
 *
 *  1. 公开群、聊天室和直播大群：只有群主或者管理员可以修改群名。
 *  2. 私有群：任何人可修改群名。
 *
 *  @param group     群组Id
 *  @param groupName 新群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupName:(NSString*)group groupName:(NSString*)groupName succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群简介
 *
 *  1. 公开群、聊天室、直播大群：只有群主或者管理员可以修改群简介。
 *  2. 私有群：任何人可修改群简介。
 *
 *  @param group            群组Id
 *  @param introduction     群简介（最长120字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupIntroduction:(NSString*)group introduction:(NSString*)introduction succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群公告
 *
 *  1. 公开群、聊天室、直播大群：只有群主或者管理员可以修改群公告。
 *  2. 私有群：任何人可修改群公告。
 *
 *  @param group            群组Id
 *  @param notification     群公告（最长150字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupNotification:(NSString*)group notification:(NSString*)notification succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群头像
 *
 *  1. 公开群、聊天室、直播大群：只有群主或者管理员可以修改群头像。
 *  2. 私有群：任何人可修改群头像。
 *
 *  @param group            群组Id
 *  @param url              群头像地址（最长100字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupFaceUrl:(NSString*)group url:(NSString*)url succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改加群选项
 *
 *  1. 公开群、聊天室、直播大群：只有群主或者管理员可以修改加群选项。
 *  2. 私有群：只能通过邀请加入群组，不能主动申请加入某个群组。
 *
 *  @param group            群组Id
 *  @param opt              加群选项，详见 TIMGroupAddOpt
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupAddOpt:(NSString*)group opt:(TIMGroupAddOpt)opt succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群自定义字段集合
 *
 *  通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群维度自定义字段 配置相关的 key 和权限。
 *
 *  @param group      群组Id
 *  @param customInfo 自定义字段集合,key 是 NSString* 类型,value 是 NSData* 类型
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupCustomInfo:(NSString*)group customInfo:(NSDictionary<NSString *,NSData *>*)customInfo succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  转让群给新群主
 *
 *  1. 只有群主才有权限进行群转让操作。
 *  2. 直播大群不能进行群转让操作。
 *
 *  @param group      群组Id
 *  @param identifier 新的群主Id
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupOwner:(NSString*)group user:(NSString*)identifier succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改接受消息选项
 *
 *  默认情况下，公开群和私有群是接收并离线推送群消息，聊天室和直播大群是接收但不离线推送群消息。
 *
 *  @param group            群组Id
 *  @param opt              接受消息选项，详见 TIMGroupReceiveMessageOpt
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyReciveMessageOpt:(NSString*)group opt:(TIMGroupReceiveMessageOpt)opt succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群成员角色
 *
 *  1. 群主、管理员：可以进行对群成员的身份进行修改。
 *  2. 直播大群：不支持修改用户群内身份。
 *
 *  @param group            群组Id
 *  @param identifier       被修改角色的用户identifier
 *  @param role             角色（注意：不能修改为群主），详见 TIMGroupMemberRole
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberInfoSetRole:(NSString*)group user:(NSString*)identifier role:(TIMGroupMemberRole)role succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  禁言用户
 *
 *  只有管理员或群主能够调用
 *
 *  @param group            群组Id
 *  @param identifier       被禁言的用户identifier
 *  @param stime            禁言时间
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberInfoSetSilence:(NSString*)group user:(NSString*)identifier stime:(uint32_t)stime succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群名片
 *
 *  只有本人、管理员或群主能够调用
 *
 *  @param group            群组Id
 *  @param identifier       被操作用户identifier
 *  @param nameCard         群名片
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberInfoSetNameCard:(NSString*)group user:(NSString*)identifier nameCard:(NSString*)nameCard succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群成员自定义字段集合
 *
 *  通过 [IM 控制台](https://console.cloud.tencent.com/avc) -> 功能配置 -> 群成员维度自定义字段 配置相关的 key 和权限。
 *
 *  @param group      群组 Id
 *  @param identifier 被操作用户 identifier
 *  @param customInfo 自定义字段集合,key 是 NSString* 类型,value 是 NSData* 类型
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberInfoSetCustomInfo:(NSString*)group user:(NSString*)identifier customInfo:(NSDictionary<NSString*,NSData*> *)customInfo succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群组是否可被搜索属性
 *
 *  @param group      群组Id
 *  @param searchable 是否能被搜索
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupSearchable:(NSString*)group searchable:(BOOL)searchable succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群组成员是否可见属性
 *
 *  @param group   群组Id
 *  @param visible 是否可见
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupMemberVisible:(NSString*)group visible:(BOOL)visible succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群组全员禁言属性
 *
 *  1. 群主、管理员：有权限进行全员禁言的操作。
 *  2. 所有群组类型：都支持全员禁言的操作。
 *
 *  @param group   群组Id
 *  @param shutup  是否禁言
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)modifyGroupAllShutup:(NSString*)group shutup:(BOOL)shutup succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取群组未决列表
 *
 *  1. 群未决消息泛指所有需要审批的群相关的操作（例如：加群待审批，拉人入群待审批等等）。即便审核通过或者拒绝后，该条信息也可通过此接口拉回，拉回的信息中有已决标志
 *  2. 审批人：有权限拉取相关信息,如果 UserA 申请加入群 GroupA，则群管理员可获取此未决相关信息，UserA 因为没有审批权限，不需要拉取未决信息。如果 AdminA 拉 UserA 进去 GroupA，则 UserA 可以拉取此未决相关信息，因为该未决信息待 UserA 审批。
 *
 *  @param option 未决参数配置
 *  @param succ   成功回调，返回未决列表
 *  @param fail   失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)getPendencyFromServer:(TIMGroupPendencyOption*)option succ:(TIMGetGroupPendencyListSucc)succ fail:(TIMFail)fail;

/**
 *  群未决已读上报
 *
 *  对于未决信息，SDK 可对其和之前的所有未决信息上报已读。上报已读后，仍然可以拉取到这些未决信息，但可通过对已读时戳的判断判定未决信息是否已读。
 *
 *  @param timestamp 上报已读时间戳
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0：成功；1：失败
 */
- (int)pendencyReport:(uint64_t)timestamp succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取用户所在群组信息(暂未实现)
 *
 *  开启本地缓存后有效
 *
 *  @param groups 群组id（NSString*）列表，nil时返回群组列表
 *
 *  @return 群组信息（TIMGroupInfo*)列表，assistant未同步时返回nil
 */
- (NSArray*)getGroupInfo:(NSArray*)groups;

@end

#endif /* TIMGroupManager_Ext_h */
