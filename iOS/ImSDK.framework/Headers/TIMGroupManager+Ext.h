//
//  TIMGroupManager+Ext.h
//  IMGroupExt
//
//  Created by tomzhu on 2017/2/9.
//
//

#ifndef TIMGroupManager_Ext_h
#define TIMGroupManager_Ext_h

#import "ImSDK.h"
#import "TIMComm+Group.h"

@interface TIMGroupManager (Ext)

/**
 *  创建私有群
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
- (int)createPrivateGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建公开群
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
- (int)createPublicGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建聊天室
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
- (int)createChatRoomGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建音视频聊天室（可支持超大群，详情可参考wiki文档）
 *
 *  @param groupName 群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
- (int)createAVChatRoomGroup:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建群组
 *
 *  @param groupInfo 群组信息
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
- (int)createGroup:(TIMCreateGroupInfo*)groupInfo succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  邀请好友入群
 *
 *  @param group   群组Id
 *  @param members 要加入的成员列表（NSString* 类型数组）
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0 成功
 */
- (int)inviteGroupMember:(NSString*)group members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  删除群成员
 *
 *  @param group   群组Id
 *  @param reason  删除原因
 *  @param members 要删除的成员列表
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0 成功
 */
- (int)deleteGroupMemberWithReason:(NSString*)group reason:(NSString*)reason members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  获取群公开信息
 *  @param groups 群组Id
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
- (int)getGroupPublicInfo:(NSArray*)groups succ:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  获取群列表
 *
 *  @param succ 成功回调，NSArray列表为 TIMGroupInfo，结构体只包含 group\groupName\groupType\faceUrl\allShutup\selfInfo 信息
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
- (int)getGroupList:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  获取群信息
 *
 *  @param succ 成功回调，不包含 selfInfo信息
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
- (int)getGroupInfo:(NSArray*)groups succ:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  获取本人在群组内的成员信息
 *
 *  @param group 群组Id
 *  @param succ  成功回调，返回信息
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
- (int)getGroupSelfInfo:(NSString*)group succ:(TIMGroupSelfSucc)succ fail:(TIMFail)fail;

/**
 *  获取接受消息选项
 *
 *  @param group            群组Id
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)getReciveMessageOpt:(NSString*)group succ:(TIMGroupReciveMessageOptSucc)succ fail:(TIMFail)fail;

/**
 *  获取群成员列表
 *
 *  @param group 群组Id
 *  @param succ  成功回调(TIMGroupMemberInfo列表)
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
- (int)getGroupMembers:(NSString*)group succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  获取群组指定成员的信息
 *
 *  @param group   群组Id
 *  @param members 成员Id（NSString*）列表
 *  @param succ    成功回调(TIMGroupMemberInfo列表)
 *  @param fail    失败回调
 *
 *  @return 0 成功
 */
- (int)getGroupMembersInfo:(NSString*)group members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  获取指定类型的成员列表（支持按字段拉取，分页）
 *
 *  @param group      群组Id：（NSString*) 列表
 *  @param filter     群成员角色过滤方式
 *  @param flags      拉取资料标志
 *  @param custom     要获取的自定义key（NSString*）列表
 *  @param nextSeq    分页拉取标志，第一次拉取填0，回调成功如果不为零，需要分页，传入再次拉取，直至为0
 *  @param succ       成功回调
 *  @param fail       失败回调
 */
- (int)getGroupMembers:(NSString*)group ByFilter:(TIMGroupMemberFilter)filter flags:(TIMGetGroupMemInfoFlag)flags custom:(NSArray*)custom nextSeq:(uint64_t)nextSeq succ:(TIMGroupMemberSuccV2)succ fail:(TIMFail)fail;

/**
 *  修改群名
 *
 *  @param group     群组Id
 *  @param groupName 新群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupName:(NSString*)group groupName:(NSString*)groupName succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群简介
 *
 *  @param group            群组Id
 *  @param introduction     群简介（最长120字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupIntroduction:(NSString*)group introduction:(NSString*)introduction succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群公告
 *
 *  @param group            群组Id
 *  @param notification     群公告（最长150字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupNotification:(NSString*)group notification:(NSString*)notification succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群头像
 *
 *  @param group            群组Id
 *  @param url              群头像地址（最长100字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupFaceUrl:(NSString*)group url:(NSString*)url succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改加群选项
 *
 *  @param group            群组Id
 *  @param opt              加群选项，详见 TIMGroupAddOpt
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupAddOpt:(NSString*)group opt:(TIMGroupAddOpt)opt succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群自定义字段集合
 *
 *  @param group      群组Id
 *  @param customInfo 自定义字段集合,key是NSString*类型,value是NSData*类型
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupCustomInfo:(NSString*)group customInfo:(NSDictionary*)customInfo succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  转让群给新群主
 *
 *  @param group      群组Id
 *  @param identifier 新的群主Id
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupOwner:(NSString*)group user:(NSString*)identifier succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改接受消息选项
 *
 *  @param group            群组Id
 *  @param opt              接受消息选项，详见 TIMGroupReceiveMessageOpt
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)modifyReciveMessageOpt:(NSString*)group opt:(TIMGroupReceiveMessageOpt)opt succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群成员角色
 *
 *  @param group            群组Id
 *  @param identifier       被修改角色的用户identifier
 *  @param role             角色（注意：不能修改为群主），详见 TIMGroupMemberRole
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupMemberInfoSetRole:(NSString*)group user:(NSString*)identifier role:(TIMGroupMemberRole)role succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  禁言用户（只有管理员或群主能够调用）
 *
 *  @param group            群组Id
 *  @param identifier       被禁言的用户identifier
 *  @param stime            禁言时间
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupMemberInfoSetSilence:(NSString*)group user:(NSString*)identifier stime:(uint32_t)stime succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群名片（只有本人、管理员或群主能够调用）
 *
 *  @param group            群组Id
 *  @param identifier       被操作用户identifier
 *  @param nameCard         群名片
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupMemberInfoSetNameCard:(NSString*)group user:(NSString*)identifier nameCard:(NSString*)nameCard succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群成员自定义字段集合
 *
 *  @param group      群组Id
 *  @param identifier 被操作用户identifier
 *  @param customInfo 自定义字段集合,key是NSString*类型,value是NSData*类型
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupMemberInfoSetCustomInfo:(NSString*)group user:(NSString*)identifier customInfo:(NSDictionary*)customInfo succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群组是否可被搜索属性
 *
 *  @param group      群组Id
 *  @param searchable 是否能被搜索
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0 成功
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
 *  @return 0 成功
 */
- (int)modifyGroupMemberVisible:(NSString*)group visible:(BOOL)visible succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群组全员禁言属性
 *
 *  @param group   群组Id
 *  @param shutup  是否禁言
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0 成功
 */
- (int)modifyGroupAllShutup:(NSString*)group shutup:(BOOL)shutup succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取群组未决列表
 *
 *  @param option 未决参数配置
 *  @param succ   成功回调，返回未决列表
 *  @param fail   失败回调
 *
 *  @return 0 成功
 */
- (int)getPendencyFromServer:(TIMGroupPendencyOption*)option succ:(TIMGetGroupPendencyListSucc)succ fail:(TIMFail)fail;

/**
 *  群未决已读上报
 *
 *  @param timestamp 上报已读时间戳
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
- (int)pendencyReport:(uint64_t)timestamp succ:(TIMSucc)succ fail:(TIMFail)fail;

#pragma mark - 开启本地缓存后有效

/**
 *  获取用户所在群组信息
 *
 *  @param groups 群组id（NSString*）列表，nil时返回群组列表
 *
 *  @return 群组信息（TIMGroupInfo*)列表，assistant未同步时返回nil
 */
- (NSArray*)getGroupInfo:(NSArray*)groups;

@end

#endif /* TIMGroupManager_Ext_h */
