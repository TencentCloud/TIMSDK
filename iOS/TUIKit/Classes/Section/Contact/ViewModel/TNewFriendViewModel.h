//
//  TNewFriendViewModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import <Foundation/Foundation.h>
#import "TCommonPendencyCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TNewFriendViewModel : NSObject

@property (readonly) NSArray *dataList;
@property BOOL hasNextData;
@property BOOL isLoading;

- (void)loadData;
- (void)loadNextData;

@end

NS_ASSUME_NONNULL_END
