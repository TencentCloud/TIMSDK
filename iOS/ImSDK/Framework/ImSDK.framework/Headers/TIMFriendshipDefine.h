//
//  TIMFriendshipDefine.h
//  imsdk
//
//  Created by annidyfeng on 2019/3/7.
//  Copyright © 2019年 Tencent. All rights reserved.
//

#ifndef TIMFriendshipDefine_h
#define TIMFriendshipDefine_h

#import "ImSDK.h"

@class TIMFriendMetaInfo;
@class TIMFriendPendencyResponse;
@class TIMFriendPendencyItem;
@class TIMFriendFutureMeta;
@class TIMFriendGroup;

#pragma mark - 枚举类型

/**
 * 好友操作状态
 */
typedef NS_ENUM(NSInteger, TIMFriendStatus) {
    /**
     *  操作成功
     */
    TIM_FRIEND_STATUS_SUCC                              = 0,
    
    /**
     *  请求参数错误，请根据错误描述检查请求是否正确
     */
    TIM_FRIEND_PARAM_INVALID                                = 30001,
    
    /**
     *  加好友时有效：自己的好友数已达系统上限
     */
    TIM_ADD_FRIEND_STATUS_SELF_FRIEND_FULL                  = 30010,
    
    /**
     * 更新好友分组时有效：分组已达系统上限
     */
    TIM_UPDATE_FRIEND_GROUP_STATUS_MAX_GROUPS_EXCEED        = 30011,
    
    /**
     *  加好友、响应好友时有效：对方的好友数已达系统上限
     */
    TIM_ADD_FRIEND_STATUS_THEIR_FRIEND_FULL                 = 30014,
    
    /**
     *  加好友时有效：被加好友在自己的黑名单中
     */
    TIM_ADD_FRIEND_STATUS_IN_SELF_BLACK_LIST                = 30515,
    
    /**
     *  加好友时有效：被加好友设置为禁止加好友
     */
    TIM_ADD_FRIEND_STATUS_FRIEND_SIDE_FORBID_ADD            = 30516,
    
    /**
     *  加好友时有效：已被被添加好友设置为黑名单
     */
    TIM_ADD_FRIEND_STATUS_IN_OTHER_SIDE_BLACK_LIST          = 30525,
    
    /**
     *  加好友时有效：等待好友审核同意
     */
    TIM_ADD_FRIEND_STATUS_PENDING                           = 30539,
    
    /**
     *  删除好友时有效：删除好友时对方不是好友
     */
    TIM_DEL_FRIEND_STATUS_NO_FRIEND                         = 31704,
    
    /**
     *  响应好友申请时有效：对方没有申请过好友
     */
    TIM_RESPONSE_FRIEND_STATUS_NO_REQ                       = 30614,
    
    /**
     *  添加黑名单有效：已经在黑名单了
     */
    TIM_ADD_BLACKLIST_FRIEND_STATUS_IN_BLACK_LIST           = 31307,
    
    /**
     *  删除黑名单有效：用户不在黑名单里
     */
    TIM_DEL_BLACKLIST_FRIEND_STATUS_NOT_IN_BLACK_LIST       = 31503,
    
    /**
     * 创建好友分组时有效：没有拉到SDKAppId
     */
    TIM_ADD_FRIEND_GROUP_STATUS_GET_SDKAPPID_FAILED         = 32207,
    
    /**
     * 创建好友分组时有效：要加入到好友分组中的用户不是好友
     */
    TIM_ADD_FRIEND_GROUP_STATUS_NOT_FRIEND                  = 32216,
    
    /**
     * 更新好友分组时有效：没有拉到SDKAppId
     */
    TIM_UPDATE_FRIEND_GROUP_STATUS_GET_SDKAPPID_FAILED      = 32511,
    
    /**
     * 更新好友分组时有效：要加入到好友分组中的用户不是好友
     */
    TIM_UPDATE_FRIEND_GROUP_STATUS_ADD_NOT_FRIEND           = 32518,
    
    /**
     * 更新好友分组时有效：要加入到好友分组中的好友已经在分组中
     */
    TIM_UPDATE_FRIEND_GROUP_STATUS_ADD_ALREADY_IN_GROUP     = 32519,
    
    /**
     * 更新好友分组时有效：要从好友分组中删除的好友不在好友分组中
     */
    TIM_UPDATE_FRIEND_GROUP_STATUS_DEL_NOT_IN_GROUP         = 32520,
    
};

typedef NS_ENUM(NSInteger, TIMDelFriendType) {
    /**
     *  删除单向好友
     */
    TIM_FRIEND_DEL_SINGLE               = 1,
    
    /**
     *  删除双向好友
     */
    TIM_FRIEND_DEL_BOTH                 = 2,
};

typedef NS_ENUM(NSInteger, TIMPendencyType) {
    /**
     *  别人发给我的
     */
    TIM_PENDENCY_COME_IN                    = 1,
    
    /**
     *  我发给别人的
     */
    TIM_PENDENCY_SEND_OUT                   = 2,
    
    /**
     * 别人发给我的 和 我发给别人的。仅拉取时有效
     */
    TIM_PENDENCY_BOTH                       = 3,
};

/**
 * 推荐好友类型
 */
typedef NS_ENUM(NSInteger, TIMFutureFriendType) {
    /**
     *  收到的未决请求
     */
    TIM_FUTURE_FRIEND_PENDENCY_IN_TYPE              = 0x1,
    
    /**
     *  发出去的未决请求
     */
    TIM_FUTURE_FRIEND_PENDENCY_OUT_TYPE             = 0x2,
    
    /**
     *  推荐好友
     */
    TIM_FUTURE_FRIEND_RECOMMEND_TYPE                = 0x4,
    
    /**
     *  已决好友
     */
    TIM_FUTURE_FRIEND_DECIDE_TYPE                   = 0x8,
};

/**
 * 翻页选项
 */
typedef NS_ENUM(NSInteger, TIMPageDirectionType) {
    /**
     *  向上翻页
     */
    TIM_PAGE_DIRECTION_UP_TYPE            = 1,
    
    /**
     *  向下翻页
     */
    TIM_PAGE_DIRECTION_DOWN_TYPE           = 2,
};

/**
 *  好友检查类型
 */
typedef NS_ENUM(NSInteger,TIMFriendCheckType) {
    /**
     *  单向好友
     */
    TIM_FRIEND_CHECK_TYPE_UNIDIRECTION     = 0x1,
    /**
     *  互为好友
     */
    TIM_FRIEND_CHECK_TYPE_BIDIRECTION      = 0x2,
};

/**
 *  好友关系类型
 */
typedef NS_ENUM(NSInteger,TIMFriendRelationType) {
    /**
     *  不是好友
     */
    TIM_FRIEND_RELATION_TYPE_NONE           = 0x0,
    /**
     *  对方在我的好友列表中
     */
    TIM_FRIEND_RELATION_TYPE_MY_UNI         = 0x1,
    /**
     *  我在对方的好友列表中
     */
    TIM_FRIEND_RELATION_TYPE_OTHER_UNI      = 0x2,
    /**
     *  互为好友
     */
    TIM_FRIEND_RELATION_TYPE_BOTH           = 0x3,
};

typedef NS_ENUM(NSInteger, TIMFriendResponseType) {
    /**
     *  同意加好友（建立单向好友）
     */
    TIM_FRIEND_RESPONSE_AGREE                       = 0,
    
    /**
     *  同意加好友并加对方为好友（建立双向好友）
     */
    TIM_FRIEND_RESPONSE_AGREE_AND_ADD               = 1,
    
    /**
     *  拒绝对方好友请求
     */
    TIM_FRIEND_RESPONSE_REJECT                      = 2,
};

#pragma mark - block回调

/**
 * 获取好友列表回调
 *
 *  @param meta 好友元信息
 *  @param friends 好友列表 TIMUserProfile* 数组，只包含需要的字段
 */
typedef void (^TIMGetFriendListByPageSucc)(TIMFriendMetaInfo * meta, NSArray * friends);

/**
 * 获取未决请求列表成功
 *
 *  @param pendencyResponse 未决请求元信息
 */
typedef void (^TIMGetFriendPendencyListSucc)(TIMFriendPendencyResponse *pendencyResponse);

/**
 *  群搜索回调
 *
 *  @param totalNum 搜索结果的总数
 *  @param users    请求的用户列表片段
 */
typedef void (^TIMUserSearchSucc)(uint64_t totalNum, NSArray * users);

/**
 *  好友分组列表
 *
 *  @param groups 好友分组（TIMFriendGroup*)列表
 */
typedef void (^TIMFriendGroupArraySucc)(NSArray<TIMFriendGroup *> * groups);

/**
 *  好友关系检查回调
 *
 *  @param results TIMCheckFriendResult列表
 */
typedef void (^TIMFriendCheckSucc)(NSArray* results);

#pragma mark - 基本类型

/**
 *  加好友请求
 */
@interface TIMFriendRequest : TIMCodingModel

/**
 *  用户identifier（必填）
 */
@property (nonatomic,strong) NSString* identifier;

/**
 *  备注（备注最大96字节）
 */
@property (nonatomic,strong) NSString* remark;

/**
 *  请求说明（最大120字节）
 */
@property (nonatomic,strong) NSString* addWording;

/**
 *  添加来源
 *  来源需要添加“AddSource_Type_”前缀
 */
@property (nonatomic,strong) NSString* addSource;

/**
 *  分组
 */
@property (nonatomic,strong) NSString* group;

@end

/**
 * 未决请求
 */
@interface TIMFriendPendencyItem : TIMCodingModel

/**
 * 用户标识
 */
@property(nonatomic,strong) NSString* identifier;
/**
 * 增加时间
 */
@property(nonatomic,assign) uint64_t addTime;
/**
 * 来源
 */
@property(nonatomic,strong) NSString* addSource;
/**
 * 加好友附言
 */
@property(nonatomic,strong) NSString* addWording;

/**
 * 加好友昵称
 */
@property(nonatomic,strong) NSString* nickname;

/**
 * 未决请求类型
 */
@property(nonatomic,assign) TIMPendencyType type;

@end

/**
 * 未决推送
 */
@interface TIMFriendPendencyInfo : TIMCodingModel
/**
 * 用户标识
 */
@property(nonatomic,strong) NSString* identifier;
/**
 * 来源
 */
@property(nonatomic,strong) NSString* addSource;
/**
 * 加好友附言
 */
@property(nonatomic,strong) NSString* addWording;

/**
 * 加好友昵称
 */
@property(nonatomic,strong) NSString* nickname;
@end

/**
 * 未决请求信息
 */
@interface TIMFriendPendencyRequest : TIMCodingModel

/**
 * 序列号，未决列表序列号
 *    建议客户端保存seq和未决列表，请求时填入server返回的seq
 *    如果seq是server最新的，则不返回数据
 */
@property(nonatomic,assign) uint64_t seq;

/**
 * 翻页时间戳，只用来翻页，server返回0时表示没有更多数据，第一次请求填0
 *    特别注意的是，如果server返回的seq跟填入的seq不同，翻页过程中，需要使用客户端原始seq请求，直到数据请求完毕，才能更新本地seq
 */
@property(nonatomic,assign) uint64_t timestamp;

/**
 * 每页的数量，即本次请求最多返回都个数据
 */
@property(nonatomic,assign) uint64_t numPerPage;

/**
 * 未决请求拉取类型
 */
@property(nonatomic,assign) TIMPendencyType type;

@end

/**
 * 未决返回信息
 */
@interface TIMFriendPendencyResponse : TIMCodingModel

/**
 * 本次请求的未决列表序列号
 */
@property(nonatomic,assign) uint64_t seq;

/**
 * 本次请求的翻页时间戳
 */
@property(nonatomic,assign) uint64_t timestamp;

/**
 * 未决请求未读数量
 */
@property(nonatomic,assign) uint64_t unreadCnt;

/**
 * 未决数据
 */
@property NSArray<TIMFriendPendencyItem *> * pendencies;

@end



/**
 * 好友元信息
 */
@interface TIMFriendMetaInfo : TIMCodingModel

/**
 * 时间戳，需要保存，下次拉取时传入，增量更新使用
 */
@property(nonatomic,assign) uint64_t timestamp;
/**
 * 序列号，需要保存，下次拉取时传入，增量更新使用
 */
@property(nonatomic,assign) uint64_t infoSeq;
/**
 * 分页信息，无需保存，返回为0时结束，非0时传入再次拉取，第一次拉取时传0
 */
@property(nonatomic,assign) uint64_t nextSeq;
/**
 * 覆盖：为TRUE时需要重设timestamp, infoSeq, nextSeq为0，清除客户端存储，重新拉取资料
 */
@property(nonatomic,assign) BOOL recover;

@end

/**
 *  好友分组信息
 */
@interface TIMFriendGroup : TIMCodingModel
/**
 *  好友分组名称
 */
@property(nonatomic,strong) NSString* name;

/**
 *  分组成员数量
 */
@property(nonatomic,assign) uint64_t userCnt;

/**
 *  分组成员identifier列表
 */
@property(nonatomic,strong) NSArray* friends;

@end

/**
 *  好友关系检查
 */
@interface TIMFriendCheckInfo : NSObject
/**
 *  检查用户的id列表（NSString*）
 */
@property(nonatomic,strong) NSArray* users;

/**
 *  检查类型
 */
@property(nonatomic,assign) TIMFriendCheckType checkType;

@end

@interface TIMCheckFriendResult : NSObject
/**
 *  用户id
 */
@property(nonatomic,strong) NSString* identifier;
/**
 *  返回状态
 */
@property(nonatomic,assign) TIMFriendStatus status;
/**
 *  检查结果
 */
@property(nonatomic,assign) TIMFriendRelationType resultType;

@end

@interface TIMFriendResult : NSObject

/**
 *  用户Id
 */
@property NSString* identifier;

/**
 * 返回码
 */
@property NSInteger result_code;

/**
 * 返回信息
 */
@property NSString *result_info;

@end

/**
 * 响应好友请求
 */
@interface TIMFriendResponse : NSObject

/**
 *  响应类型
 */
@property(nonatomic,assign) TIMFriendResponseType responseType;

/**
 *  用户identifier
 */
@property(nonatomic,strong) NSString* identifier;

/**
 *  备注好友（可选，如果要加对方为好友）。备注最大96字节
 */
@property(nonatomic,strong) NSString* remark;

@end


/**
 *  好友分组信息扩展
 */
@interface TIMFriendGroupWithProfiles : TIMFriendGroup
/**
 *  好友资料（TIMUserProfile*）列表
 */
@property(nonatomic,strong) NSArray* profiles;
@end

// 用户资料KEY

/**
 * 昵称
 * 值类型: NSString
 */
extern NSString *const TIMProfileTypeKey_Nick;
/**
 * 头像
 * 值类型: NSString
 */
extern NSString *const TIMProfileTypeKey_FaceUrl;
/**
 * 好友申请
 * 值类型: NSNumber [TIM_FRIEND_ALLOW_ANY,TIM_FRIEND_NEED_CONFIRM,TIM_FRIEND_DENY_ANY]
 */
extern NSString *const TIMProfileTypeKey_AllowType;
/**
 * 性别
 * 值类型: NSNumber [TIM_GENDER_UNKNOWN,TIM_GENDER_MALE,TIM_GENDER_FEMALE]
 */
extern NSString *const TIMProfileTypeKey_Gender;
/**
 * 生日
 * 值类型: NSNumber
 */
extern NSString *const TIMProfileTypeKey_Birthday;
/**
 * 位置
 * 值类型: NSString
 */
extern NSString *const TIMProfileTypeKey_Location;
/**
 * 语言
 * 值类型: NSNumber
 */
extern NSString *const TIMProfileTypeKey_Language;
/**
 * 等级
 * 值类型: NSNumber
 */
extern NSString *const TIMProfileTypeKey_Level;
/**
 * 角色
 * 值类型: NSNumber
 */
extern NSString *const TIMProfileTypeKey_Role;
/**
 * 签名
 * 值类型: NSString
 */
extern NSString *const TIMProfileTypeKey_SelfSignature;
/**
 * 自定义字段前缀
 * 值类型: [NSString,NSData|NSNumber]
 * @note 当设置自定义字的值NSString对象时，后台会将其转为UTF8保存在数据库中。由于部分用户迁移资料时可能不是UTF8类型，所以在获取资料时，统一返回NSData类型。
 */
extern NSString *const TIMProfileTypeKey_Custom_Prefix;

// 好友资料KEY

/**
 * 备注
 * 值类型: NSString
 */
extern NSString *const TIMFriendTypeKey_Remark;
/**
 * 分组
 * 值类型: [NSArray]
 */
extern NSString *const TIMFriendTypeKey_Group;
/**
 * 自定义字段前缀
 * 值类型: [NSString,NSData|NSNumber]
 */
extern NSString *const TIMFriendTypeKey_Custom_Prefix;
#endif /* TIMFriendshipDefine_h */

