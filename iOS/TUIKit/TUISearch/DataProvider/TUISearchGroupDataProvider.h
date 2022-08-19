//
//  TUISearchGroupDataProvider.h
//  Pods
//
//  Created by harvy on 2021/3/30.
//

#import <Foundation/Foundation.h>
#import "TUIDefine.h"

@class TUISearchGroupResult;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUISearchGroupMatchField) {
    TUISearchGroupMatchFieldGroupID         = 0x1 << 1,
    TUISearchGroupMatchFieldGroupName       = 0x1 << 2,
    TUISearchGroupMatchFieldMember          = 0x1 << 3,
};

typedef NS_ENUM(NSInteger, TUISearchGroupMemberMatchField) {
    TUISearchGroupMemberMatchFieldUserID    = 0x1 << 1,
    TUISearchGroupMemberMatchFieldNickName  = 0x1 << 2,
    TUISearchGroupMemberMatchFieldRemark    = 0x1 << 3,
    TUISearchGroupMemberMatchFieldNameCard  = 0x1 << 4,
};

typedef void(^TUISearchGroupResultListSucc)(NSArray<TUISearchGroupResult *> *resultSet);
typedef void(^TUISearchGroupResultListFail)(NSInteger code, NSString *desc);

#pragma mark - Paramter
@interface TUISearchGroupParam : NSObject

@property (nonatomic, copy) NSArray<NSString *> *keywordList;

@property (nonatomic, assign) BOOL isSearchGroupID;
@property (nonatomic, assign) BOOL isSearchGroupName;
@property (nonatomic, assign) BOOL isSearchGroupMember;


@property (nonatomic, assign) BOOL isSearchMemberUserID;
@property (nonatomic, assign) BOOL isSearchMemberNickName;
@property (nonatomic, assign) BOOL isSearchMemberRemark;
@property (nonatomic, assign) BOOL isSearchMemberNameCard;

@end

#pragma mark - Group member match result
@interface TUISearchGroupMemberMatchResult : NSObject

@property (nonatomic, strong, readonly) V2TIMGroupMemberFullInfo *memberInfo;
@property (nonatomic, assign, readonly) TUISearchGroupMemberMatchField memberMatchField;
@property (nonatomic, copy, readonly) NSString *memberMatchValue;

@end


#pragma mark - Group match result
@interface TUISearchGroupResult : NSObject

@property (nonatomic, strong, readonly) V2TIMGroupInfo *groupInfo;
@property (nonatomic, assign, readonly) TUISearchGroupMatchField matchField;
@property (nonatomic, copy, readonly) NSString * __nullable matchValue;
@property (nonatomic, strong, readonly) NSArray<TUISearchGroupMemberMatchResult *> * __nullable matchMembers;

@end

#pragma mark - Group Search
@interface TUISearchGroupDataProvider : NSObject

+ (void)searchGroups:(TUISearchGroupParam *)searchParam succ:(TUISearchGroupResultListSucc __nullable)succ fail:(TUISearchGroupResultListFail __nullable)fail;

@end

NS_ASSUME_NONNULL_END
