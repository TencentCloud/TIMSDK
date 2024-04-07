//
//  TUIFindContactCellModel_Minimalist.h
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class V2TIMUserFullInfo;
@class V2TIMGroupInfo;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIFindContactType_Minimalist) {
    TUIFindContactTypeC2C_Minimalist = 1,
    TUIFindContactTypeGroup_Minimalist = 2,
};

@class TUIFindContactCellModel_Minimalist;
typedef void (^TUIFindContactOnCallback_Minimalist)(TUIFindContactCellModel_Minimalist *);

@interface TUIFindContactCellModel_Minimalist : NSObject

@property(nonatomic, assign) TUIFindContactType_Minimalist type;
@property(nonatomic, strong) UIImage *avatar;
@property(nonatomic, strong) NSURL *avatarUrl;
@property(nonatomic, copy) NSString *mainTitle;
@property(nonatomic, copy) NSString *subTitle;
@property(nonatomic, copy) NSString *desc;

/**
 * c2c-> userID,   group->groupID
 * If the conversation type is c2c, contactID represents userid; if the conversation type is group, contactID represents groupID
 */
@property(nonatomic, copy) NSString *contactID;
@property(nonatomic, strong) V2TIMUserFullInfo *userInfo;
@property(nonatomic, strong) V2TIMGroupInfo *groupInfo;

@property(nonatomic, copy) TUIFindContactOnCallback_Minimalist onClick;

@end

NS_ASSUME_NONNULL_END
