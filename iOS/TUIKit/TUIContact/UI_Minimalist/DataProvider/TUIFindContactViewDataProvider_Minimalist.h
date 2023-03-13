//
//  TUIFindContactViewDataProvider.h
//  TUIContact
//
//  Created by harvy on 2021/12/13.
//

#import <Foundation/Foundation.h>
#import "TUIFindContactCellModel_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIFindContactViewDataProvider_Minimalist : NSObject

@property (nonatomic, strong, readonly) NSArray<TUIFindContactCellModel_Minimalist *> *users;
@property (nonatomic, strong, readonly) NSArray<TUIFindContactCellModel_Minimalist *> *groups;

- (void)findUser:(NSString *)userID completion:(dispatch_block_t)completion;
- (void)findGroup:(NSString *)groupID completion:(dispatch_block_t)completion;

- (NSString *)getMyUserIDDescription;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
