//
//  TIMComm+Group.h
//  IMGroupExt
//
//  Created by tomzhu on 2017/2/9.
//
//

#ifndef TIMComm_Group_h
#define TIMComm_Group_h

#import "TIMComm.h"

@class TIMGroupPendencyMeta;
@class TIMCreateGroupMemberInfo;

#pragma mark - 枚举类型

/**
 * 群基本获取资料标志
 */
typedef NS_ENUM(NSInteger, TIMGetGroupBaseInfoFlag) {
    /**
     *  不获取群组资料
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_NONE                           = 0x00,
    /**
     *  获取群组名
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_NAME                           = 0x01,
    /**
     *  获取创建时间
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_CREATE_TIME                    = 0x01 << 1,
    /**
     *  获取群主id
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_OWNER_UIN                      = 0x01 << 2,
    /**
     *  （不可用）
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_SEQ                            = 0x01 << 3,
    /**
     *  获取最近一次修改群信息时间
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_TIME                           = 0x01 << 4,
    /**
     *  （不可用）
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_NEXT_MSG_SEQ                   = 0x01 << 5,
    /**
     *  获取最近一次发消息时间
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_LAST_MSG_TIME                  = 0x01 << 6,
    /**
     *  （不可用）
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_APP_ID                         = 0x01 << 7,
    /**
     *  获取群成员数量
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_MEMBER_NUM                     = 0x01 << 8,
    /**
     *  获取最大群成员数量
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_MAX_MEMBER_NUM                 = 0x01 << 9,
    /**
     *  获取群公告
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_NOTIFICATION                   = 0x01 << 10,
    /**
     *  获取群简介
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_INTRODUCTION                   = 0x01 << 11,
    /**
     *  获取群头像
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_FACE_URL                       = 0x01 << 12,
    /**
     *  获取入群类型
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_ADD_OPTION                     = 0x01 << 13,
    /**
     *  获取群组类型
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_GROUP_TYPE                     = 0x01 << 14,
    /**
     *  获取最后一条群消息
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_LAST_MSG                       = 0x01 << 15,
    /**
     *  获取在线人数
     */
    TIM_GET_GROUP_BASE_INFO_FLAG_ONLINE_NUM                     = 0x01 << 16,
    /**
     *  获取群成员是否可见标志
     */
    TIM_GET_GROUP_BASE_INFO_VISIBLE                             = 0x01 << 17,
    /**
     *  获取群是否能被搜到标志
     */
    TIM_GET_GROUP_BASE_INFO_SEARCHABLE                          = 0x01 << 18,
    /**
     *  获取群全员禁言时间
     */
    TIM_GET_GROUP_BASE_INFO_ALL_SHUTUP                          = 0x01 << 19
};

/**
 *  群成员角色过滤方式
 */
typedef NS_ENUM(NSInteger, TIMGroupMemberFilter) {
    /**
     *  全部成员
     */
    TIM_GROUP_MEMBER_FILTER_ALL            = 0x00,
    /**
     *  群主
     */
    TIM_GROUP_MEMBER_FILTER_SUPER          = 0x01,
    /**
     *  管理员
     */
    TIM_GROUP_MEMBER_FILTER_ADMIN          = 0x02,
    /**
     *  普通成员
     */
    TIM_GROUP_MEMBER_FILTER_COMMON         = 0x04,
};

/**
 * 群成员获取资料标志
 */
typedef NS_ENUM(NSInteger, TIMGetGroupMemInfoFlag) {
    
    /**
     * 入群时间
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_JOIN_TIME                    = 0x01,
    /**
     * 消息标志
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_MSG_FLAG                     = 0x01 << 1,
    /**
     * 角色
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_ROLE_INFO                    = 0x01 << 3,
    /**
     * 禁言时间
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_SHUTUP_TIME                  = 0x01 << 4,
    /**
     * 群名片
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_NAME_CARD                    = 0x01 << 5,
};

/**
 *  群组操作结果
 */
typedef NS_ENUM(NSInteger, TIMGroupMemberStatus) {
    /**
     *  操作失败
     */
    TIM_GROUP_MEMBER_STATUS_FAIL              = 0,
    
    /**
     *  操作成功
     */
    TIM_GROUP_MEMBER_STATUS_SUCC              = 1,
    
    /**
     *  无效操作，加群时已经是群成员，移除群组时不在群内
     */
    TIM_GROUP_MEMBER_STATUS_INVALID           = 2,
    
    /**
     *  等待处理，邀请入群时等待对方处理
     */
    TIM_GROUP_MEMBER_STATUS_PENDING           = 3,
};

typedef NS_ENUM(NSInteger, TIMGroupPendencyGetType) {
    /**
     *  申请入群
     */
    TIM_GROUP_PENDENCY_GET_TYPE_JOIN            = 0x0,
    /**
     *  邀请入群
     */
    TIM_GROUP_PENDENCY_GET_TYPE_INVITE          = 0x1,
};

typedef NS_ENUM(NSInteger, TIMGroupPendencyHandleStatus) {
    /**
     *  未处理
     */
    TIM_GROUP_PENDENCY_HANDLE_STATUS_UNHANDLED            = 0,
    /**
     *  被他人处理
     */
    TIM_GROUP_PENDENCY_HANDLE_STATUS_OTHER_HANDLED        = 1,
    /**
     *  被用户处理
     */
    TIM_GROUP_PENDENCY_HANDLE_STATUS_OPERATOR_HANDLED     = 2,
};

typedef NS_ENUM(NSInteger, TIMGroupPendencyHandleResult) {
    /**
     *  拒绝申请
     */
    TIM_GROUP_PENDENCY_HANDLE_RESULT_REFUSE       = 0,
    /**
     *  同意申请
     */
    TIM_GROUP_PENDENCY_HANDLE_RESULT_AGREE        = 1,
};

#pragma mark - block回调

/**
 *  群成员列表回调
 *
 *  @param members 群成员列表，成员类型 TIMGroupMemberInfo
 */
typedef void (^TIMGroupMemberSucc)(NSArray * members);

/**
 *  群列表回调
 *
 *  @param arr 群列表，成员类型 TIMGroupInfo
 */
typedef void (^TIMGroupListSucc)(NSArray * arr);

/**
 *  本人群组内成员信息回调
 *
 *  @param selfInfo 本人成员信息
 */
typedef void (^TIMGroupSelfSucc)(TIMGroupMemberInfo * selfInfo);

/**
 *  群接受消息选项回调
 *
 *  @param opt 群接受消息选项
 */
typedef void (^TIMGroupReciveMessageOptSucc)(TIMGroupReceiveMessageOpt opt);

/**
 *  群成员列表回调（分页使用）
 *
 *  @param members 群成员（TIMGroupMemberInfo*）列表
 */
typedef void (^TIMGroupMemberSuccV2)(uint64_t nextSeq, NSArray * members);

/**
 *  群搜索回调
 *
 *  @param totalNum 搜索结果的总数
 *  @param groups  请求的群列表片段
 */
typedef void (^TIMGroupSearchSucc)(uint64_t totalNum, NSArray * groups);

/**
 *  获取群组未决请求列表成功
 *
 *  @param meta       未决请求元信息
 *  @param pendencies 未决请求列表（TIMGroupPendencyItem）数组
 */
typedef void (^TIMGetGroupPendencyListSucc)(TIMGroupPendencyMeta * meta, NSArray * pendencies);

#pragma mark - 基本类型

/**
 *  创建群参数
 */
@interface TIMCreateGroupInfo : TIMCodingModel

/**
 *  群组Id,nil则使用系统默认Id
 */
@property(nonatomic,strong) NSString* group;

/**
 *  群名
 */
@property(nonatomic,strong) NSString* groupName;

/**
 *  群类型：Private,Public,ChatRoom,AVChatRoom,BChatRoom
 */
@property(nonatomic,strong) NSString* groupType;

/**
 *  是否设置入群选项，Private类型群组请设置为false
 */
@property(nonatomic,assign) BOOL setAddOpt;

/**
 *  入群选项
 */
@property(nonatomic,assign) TIMGroupAddOpt addOpt;

/**
 *  最大成员数，填0则系统使用默认值
 */
@property(nonatomic,assign) uint32_t maxMemberNum;

/**
 *  群公告
 */
@property(nonatomic,strong) NSString* notification;

/**
 *  群简介
 */
@property(nonatomic,strong) NSString* introduction;

/**
 *  群头像
 */
@property(nonatomic,strong) NSString* faceURL;

/**
 *  自定义字段集合,key是NSString*类型,value是NSData*类型
 */
@property(nonatomic,strong) NSDictionary* customInfo;

/**
 *  创建成员（TIMCreateGroupMemberInfo*）列表
 */
@property(nonatomic,strong) NSArray <TIMCreateGroupMemberInfo *>* membersInfo;

@end

/**
 * 未决请求选项
 */
@interface TIMGroupPendencyOption : TIMCodingModel

/**
 *  拉取的起始时间 0：拉取最新的
 */
@property(nonatomic,assign) uint64_t timestamp;

/**
 *  每页的数量
 */
@property(nonatomic,assign) uint32_t numPerPage;
@end

/**
 *  未决请求元信息
 */
@interface TIMGroupPendencyMeta : TIMCodingModel

/**
 *  下一次拉取的起始时间戳
 */
@property(nonatomic,assign) uint64_t nextStartTime;

/**
 *  已读时间戳大小
 */
@property(nonatomic,assign) uint64_t readTimeSeq;

/**
 *  未决未读数
 */
@property(nonatomic,assign) uint32_t unReadCnt;

@end

/**
 *  创建群组时的成员信息
 */
@interface TIMCreateGroupMemberInfo : TIMCodingModel

/**
 *  被操作成员
 */
@property(nonatomic,strong) NSString* member;

/**
 *  成员类型
 */
@property(nonatomic,assign) TIMGroupMemberRole role;

/**
 *  自定义字段集合,key是NSString*类型,value是NSData*类型
 */
@property(nonatomic,strong) NSDictionary* customInfo;

@end

/**
 *  成员操作返回值
 */
@interface TIMGroupMemberResult : NSObject

/**
 *  被操作成员
 */
@property(nonatomic,strong) NSString* member;
/**
 *  返回状态
 */
@property(nonatomic,assign) TIMGroupMemberStatus status;

@end

/**
 *  未决申请
 */
@interface TIMGroupPendencyItem : TIMCodingModel

/**
 *  相关群组id
 */
@property(nonatomic,strong) NSString* groupId;

/**
 *  请求者id，请求加群:请求者，邀请加群:邀请人
 */
@property(nonatomic,strong) NSString* fromUser;

/**
 *  判决者id，请求加群:0，邀请加群:被邀请人
 */
@property(nonatomic,strong) NSString* toUser;

/**
 *  未决添加时间
 */
@property(nonatomic,assign) uint64_t addTime;

/**
 *  未决请求类型
 */
@property(nonatomic,assign) TIMGroupPendencyGetType getType;

/**
 *  已决标志
 */
@property(nonatomic,assign) TIMGroupPendencyHandleStatus handleStatus;

/**
 *  已决结果
 */
@property(nonatomic,assign) TIMGroupPendencyHandleResult handleResult;

/**
 *  申请或邀请附加信息
 */
@property(nonatomic,strong) NSString* requestMsg;

/**
 *  审批信息：同意或拒绝信息
 */
@property(nonatomic,strong) NSString* handledMsg;


/**
 *  同意申请
 *
 *  @param msg      同意理由，选填
 *  @param succ     成功回调
 *  @param fail     失败回调，返回错误码和错误描述
 */
-(void) accept:(NSString*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  拒绝申请
 *
 *  @param msg      拒绝理由，选填
 *  @param succ     成功回调
 *  @param fail     失败回调，返回错误码和错误描述
 */
-(void) refuse:(NSString*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;


/**
 *  用户自己的id
 */
@property(nonatomic,strong) NSString* selfIdentifier;

@end

#endif /* TIMComm_Group_h */
