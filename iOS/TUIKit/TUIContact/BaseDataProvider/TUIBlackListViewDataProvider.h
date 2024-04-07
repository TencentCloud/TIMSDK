
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**

 *  This file declares the view model used to implement the blocklist page.
 *  The view model is responsible for some data processing and business logic in the interface, such as pulling blacklist information and loading blocklist
 * data.
 */

#import <Foundation/Foundation.h>
#import "TUICommonContactCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【Module name】 TUIBlackListViewModel
 * 【Function description】It is responsible for pulling the user's blocklist information and displaying it on the page.
 *  The view model is also responsible for loading the pulled information to facilitate data processing in the client.
 */
@interface TUIBlackListViewDataProvider : NSObject

/**
 *  Bocklist data
 *  The blocklist stores the detailed information of the blocked users.
 *  Include details such as user avatar (URL and image), user ID, user nickname, etc. Used to display detailed information when you click to a detailed meeting.
 */
@property(readonly) NSArray<TUICommonContactCellData *> *blackListData;

@property(readonly) BOOL isLoadFinished;

- (void)loadBlackList;

@end

NS_ASSUME_NONNULL_END
