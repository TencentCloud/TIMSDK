
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**

 *  This file declares the view model for the friend selection interface
 *  The view model is responsible for pulling friend data through the IM SDK interface and loading the data.
 */
#import <Foundation/Foundation.h>
@class TUICommonContactSelectCellData;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^ContactSelectFilterBlock)(TUICommonContactSelectCellData *data);

/**
 * 【Module name】Friend selection interface view model (TContactSelectViewModel)
 * 【Function description】Implement the friend selection interface view model.
 *  This view model is responsible for pulling friend lists, friend requests and loading related data from the server.
 *  At the same time, this view model will also group friends according to the initials of their nicknames, which helps the view maintain an "alphabet" on the
 * right side of the interface to quickly retrieve friends.
 */
@interface TUIContactSelectViewDataProvider : NSObject

/**
 *  Data dictionary, responsible for classifying friend information (TCommonContactCellData) by initials.
 *  For example, Jack and James are stored in "J".
 */
@property(readonly) NSDictionary<NSString *, NSArray<TUICommonContactSelectCellData *> *> *dataDict;

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
 * 
 * Filter to disable contacts
 */
@property(copy) ContactSelectFilterBlock disableFilter;

/**
 * 
 * Filter to display contacts
 */
@property(copy) ContactSelectFilterBlock avaliableFilter;

- (void)loadContacts;

- (void)setSourceIds:(NSArray<NSString *> *)ids;
- (void)setSourceIds:(NSArray<NSString *> *)ids displayNames:(NSDictionary *__nullable)displayNames;

@end

NS_ASSUME_NONNULL_END
