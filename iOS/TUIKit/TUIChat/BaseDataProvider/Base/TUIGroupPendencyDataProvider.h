
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <Foundation/Foundation.h>
@class TUIGroupPendencyCellData;

NS_ASSUME_NONNULL_BEGIN

/**
 *
 * 【Module name】 TUIGroupPendencyViewModel
 * 【Function description】Group request view model
 *  This view model is responsible for unified processing of group request messages. For example, a series of logics such as obtaining the unread count,
 * receiving new request messages and updating them, agreeing/removing data in the existing data queue, etc.
 */
@interface TUIGroupPendencyDataProvider : NSObject

/**
 *  Request data list
 *  The object type stored in this list is TUIGroupPendencyCellData.
 *  That is, this array stores all pending request data of the current group, and this attribute is read-only and cannot be modified.
 */
@property(readonly) NSArray *dataList;

/**
 *
 *  Whether to have next request data.
 *  When loading data, hasNextData is YES when the request list of the current group has not been read out.
 */
@property BOOL hasNextData;

/**
 *
 *  Loading identifier
 *  When the current view model is loading data, this property is YES. At this time, loading again is not allowed until the current loading process is
 * completed.
 */
@property BOOL isLoading;

/**
 *
 *  Unread count, that is, the number of outstanding requests for the current group.
 */
@property int unReadCnt;

/**
 *
 *  group ID
 *  It is used to identify the current group and determine whether the request to join the group is a request for this group.
 */
@property NSString *groupId;

/**
 *  
 *  Load data
 *  1. First determine whether it is currently loading, and if so, terminate this loading.
 *  2. Pull the request data from the server through the getPendencyFromServer interface provided by the TIMGroupManager class in the IM SDK. The default is 100
 * requests per page.
 *  3. For the pulled data, determine whether the group ID corresponding to the request is the same as this group, and if so, convert the request to
 * TUIGroupPendencyCellData and store it in the datalist. (The request object pulled from the server is TIMGroupPendencyItem).
 */
- (void)loadData;

/**
 *  Approve current request data.
 *  This function directly calls accept implemented in TUIGroupPendencyCellData, and the unread count is decremented by 1.
 */
- (void)acceptData:(TUIGroupPendencyCellData *)data;

/**
 *  Deny the current request data.
 *  Remove the data in the parameter from the datalist, and call reject implemented in TUIGroupPendencyCellData, while the unread count is decremented by 1.
 */
- (void)removeData:(TUIGroupPendencyCellData *)data;

@end

NS_ASSUME_NONNULL_END
