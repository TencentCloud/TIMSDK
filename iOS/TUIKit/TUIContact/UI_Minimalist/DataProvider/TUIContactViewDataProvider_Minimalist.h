
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This file declares the view model for the Contacts interface.
 *  The view model is responsible for pulling friend lists, friend requests from the server and loading related data.
 */

#import <Foundation/Foundation.h>
#import "TUICommonContactCell_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【Module name】Message List View Model (TContactViewModel)
 * 【Function description】A view model that implements a message list.
 *  1. This view model is responsible for pulling friend lists, friend requests and loading related data from the server.
 *  2. At the same time, this view model will also group friends by the first latter of their nicknames, which helps the view maintain an "alphabet" on the
 * right side of the interface to facilitate quick retrieval of friends.
 */
@interface TUIContactViewDataProvider_Minimalist : NSObject

/**
 *  Data dictionary, responsible for classifying friend information (TCommonContactCellData) by initials.
 *  For example, Jack and James are stored in "J".
 */
@property(readonly) NSDictionary<NSString *, NSArray<TUICommonContactCellData_Minimalist *> *> *dataDict;

/**
 *  The group list, that is, the group information of the current friend.
 *  For example, if the current user has only one friend "Jack", there is only one element "J" in this list.
 *  The grouping information is up to 26 letters from A - Z and "#".
 */
@property(readonly) NSArray *groupList;

/**
 *  An identifier indicating whether the current loading process is complete
 *  YES: Loading is done; NO: Loading
 *  With this identifier, we can avoid reloading the data.
 */
@property(readonly) BOOL isLoadFinished;

/**
 *  Count of pending friend requests
 */
@property(readonly) NSUInteger pendencyCnt;

- (void)loadContacts;

- (void)loadFriendApplication;

- (void)clearApplicationCnt;

@end

NS_ASSUME_NONNULL_END
