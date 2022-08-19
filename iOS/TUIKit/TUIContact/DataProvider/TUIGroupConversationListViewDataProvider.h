/**
 *
 *  本文件声明了群列表界面的视图模型。
 *  视图模型负责通过 IM SDK 提供的接口拉取群列表数据并进行加载，方便页面对群列表进行展示。
 *
 *  This file declares the view model for the group list interface.
 *  The view model is responsible for pulling and loading the group list data through the interface provided by the IM SDK, which is convenient for the page to display the group list.
 */

#import <Foundation/Foundation.h>
#import "TUICommonContactCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】群组列表视图模型（TUIGroupConversationListViewModel）
 * 【功能说明】负责拉取用户的所在的群组信息，并将获得数据进行加载。
 *  视图模型通过 IM SDK 提供的接口拉取用户所在的群组信息。并将群组信息按名称首字母分类存放。
 *
 * 【Module name】Group List View Model (TUIGroupConversationListViewModel)
 * 【Function description】It is responsible for pulling the group information of the user and loading the obtained data.
 *  The view model pulls the group information of the user through the interface provided by the IM SDK. The group information is classified and stored according to the first latter of the name.
 */
@interface TUIGroupConversationListViewDataProvider : NSObject

@property (readonly) NSDictionary<NSString *, NSArray<TUICommonContactCellData *> *> *dataDict;

@property (readonly) NSArray *groupList;

@property (readonly) BOOL isLoadFinished;

- (void)loadConversation;

- (void)removeData:(TUICommonContactCellData *)data;

@end

NS_ASSUME_NONNULL_END
