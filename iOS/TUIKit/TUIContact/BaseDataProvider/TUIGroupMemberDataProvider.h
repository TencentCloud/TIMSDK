//
//  TUIGroupMemberDataProvider.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/7/2.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@import ImSDK_Plus;
@class TUIGroupMemberCellData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupMemberDataProvider : NSObject
@property(nonatomic, strong) V2TIMGroupInfo *groupInfo;
@property(nonatomic, assign) BOOL isNoMoreData;

- (instancetype)initWithGroupID:(NSString *)groupID;
- (void)loadDatas:(void (^)(BOOL success, NSString *err, NSArray *datas))completion;
@end

NS_ASSUME_NONNULL_END
