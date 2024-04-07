
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This file declares the view model for the group list interface.
 *  The view model is responsible for pulling and loading the group list data through the interface provided by the IM SDK, which is convenient for the page to
 * display the group list.
 */

#import <Foundation/Foundation.h>
#import "TUICommonContactCell_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【Module name】Group List View Model (TUIGroupConversationListViewModel)
 * 【Function description】It is responsible for pulling the group information of the user and loading the obtained data.
 *  The view model pulls the group information of the user through the interface provided by the IM SDK. The group information is classified and stored
 * according to the first latter of the name.
 */
@interface TUIGroupConversationListViewDataProvider_Minimalist : NSObject

@property(readonly) NSDictionary<NSString *, NSArray<TUICommonContactCellData_Minimalist *> *> *dataDict;

@property(readonly) NSArray *groupList;

@property(readonly) BOOL isLoadFinished;

- (void)loadConversation;

- (void)removeData:(TUICommonContactCellData_Minimalist *)data;

@end

NS_ASSUME_NONNULL_END
