//
//  TUISearchGroupDataProvider.h
//  Pods
//
//  Created by harvy on 2021/3/30.
//

#import <Foundation/Foundation.h>
#import "THeader.h"

@class TUISearchGroupResult;

NS_ASSUME_NONNULL_BEGIN

/// 群搜索匹配字段
typedef NS_ENUM(NSInteger, TUISearchGroupMatchField) {
    TUISearchGroupMatchFieldGroupID         = 0x1 << 1,   // 搜索时匹配群id
    TUISearchGroupMatchFieldGroupName       = 0x1 << 2,   // 搜索时匹配群名称
    TUISearchGroupMatchFieldMember          = 0x1 << 3,   // 搜索时匹配群成员
};

/// 群搜索时匹配群成员字段
typedef NS_ENUM(NSInteger, TUISearchGroupMemberMatchField) {
    TUISearchGroupMemberMatchFieldUserID    = 0x1 << 1,   // 搜索群成员时匹配成员ID
    TUISearchGroupMemberMatchFieldNickName  = 0x1 << 2,   // 搜索群成员时匹配成员昵称
    TUISearchGroupMemberMatchFieldRemark    = 0x1 << 3,   // 搜索群成员时匹配成员备注
    TUISearchGroupMemberMatchFieldNameCard  = 0x1 << 4,   // 搜索群成员时匹配成员名片
};

typedef void(^TUISearchGroupResultListSucc)(NSArray<TUISearchGroupResult *> *resultSet);
typedef void(^TUISearchGroupResultListFail)(NSInteger code, NSString *desc);

#pragma mark - 搜索参数
@interface TUISearchGroupParam : NSObject

/**
 * 搜索关键字列表，最多支持 5 个
 */
@property (nonatomic, copy) NSArray<NSString *> *keywordList;

/**
 * 群搜索字段：是否搜索群组 ID
 */
@property (nonatomic, assign) BOOL isSearchGroupID;

/**
 * 群搜索字段：是否搜索群名称
 */
@property (nonatomic, assign) BOOL isSearchGroupName;

/**
 * 群搜索字段：是否搜索群成员
 */
@property (nonatomic, assign) BOOL isSearchGroupMember;

/**
 * 群成员搜索字段：是否搜索成员ID，@isSearchGroupMember 为 YES 时该字段有效
 */
@property (nonatomic, assign) BOOL isSearchMemberUserID;

/**
 * 群成员搜索字段：是否搜索群昵称，@isSearchGroupMember 为 YES 时该字段有效
 */
@property (nonatomic, assign) BOOL isSearchMemberNickName;

/**
 * 群成员搜索字段：是否搜索成员备注，@isSearchGroupMember 为 YES 时该字段有效
 */
@property (nonatomic, assign) BOOL isSearchMemberRemark;

/**
 * 群成员搜索字段：是否搜索成员名片，@isSearchGroupMember 为 YES 时该字段有效
 */
@property (nonatomic, assign) BOOL isSearchMemberNameCard;

@end

#pragma mark - 群成员匹配结果
@interface TUISearchGroupMemberMatchResult : NSObject

/**
 * 群成员信息
 */
@property (nonatomic, strong, readonly) V2TIMGroupMemberFullInfo *memberInfo;

/**
 * 群成员匹配字段，详见 @TUISearchGroupMemberMatchField
 */
@property (nonatomic, assign, readonly) TUISearchGroupMemberMatchField memberMatchField;

/**
 * 群成员匹配字段对应的值
 */
@property (nonatomic, copy, readonly) NSString *memberMatchValue;

@end


#pragma mark - 搜索匹配结果
@interface TUISearchGroupResult : NSObject

/**
 * 搜索到的群组信息
 */
@property (nonatomic, strong, readonly) V2TIMGroupInfo *groupInfo;

/**
 * 匹配字段类型
 */
@property (nonatomic, assign, readonly) TUISearchGroupMatchField matchField;

/**
 * 匹配字段对应的值
 *
 * @note 当 matchField 包含 TUISearchGroupMatchFieldMember 时，该字段无效。
 */
@property (nonatomic, copy, readonly) NSString * __nullable matchValue;

/**
 * 匹配到的群成员信息
 *
 * @note 当 matchField 不包含 TUISearchGroupMatchFieldMember 时，该字段不生效。
 */
@property (nonatomic, strong, readonly) NSArray<TUISearchGroupMemberMatchResult *> * __nullable matchMembers;

@end

#pragma mark - 群搜索接口类
@interface TUISearchGroupDataProvider : NSObject

/**
 * 群搜索
 *
 * @param searchParam 搜索参数
 * @param succ 成功后的回调
 * @param fail 失败后的回调
 *
 * @note 搜索关键字最多支持 5 个
 */
+ (void)searchGroups:(TUISearchGroupParam *)searchParam succ:(TUISearchGroupResultListSucc __nullable)succ fail:(TUISearchGroupResultListFail __nullable)fail;

@end

NS_ASSUME_NONNULL_END
