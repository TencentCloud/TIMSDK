//
//  TBlackListViewModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import <Foundation/Foundation.h>
#import "TCommonContactCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TBlackListViewModel : NSObject

@property (readonly) NSArray<TCommonContactCellData *> *blackListData;
@property (readonly) BOOL isLoadFinished;

- (void)loadBlackList;

@end

NS_ASSUME_NONNULL_END
