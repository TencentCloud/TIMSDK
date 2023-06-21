//
//  TUIFindContactViewDataProvider.h
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIFindContactCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIFindContactViewDataProvider : NSObject

@property(nonatomic, strong, readonly) NSArray<TUIFindContactCellModel *> *users;
@property(nonatomic, strong, readonly) NSArray<TUIFindContactCellModel *> *groups;

- (void)findUser:(NSString *)userID completion:(dispatch_block_t)completion;
- (void)findGroup:(NSString *)groupID completion:(dispatch_block_t)completion;

- (NSString *)getMyUserIDDescription;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
