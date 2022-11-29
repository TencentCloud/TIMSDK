/**
 *
 *  本文件声明了通讯录界面的视图模型。
 *  视图模型负责从服务器拉取好友列表、好友请求并将相关数据加载。
 *
 *  This file declares the view model for the Contacts interface.
 *  The view model is responsible for pulling friend lists, friend requests from the server and loading related data.
 */

#import <Foundation/Foundation.h>
#import "TUICommonContactCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】消息列表视图模型（TContactViewModel）
 * 【功能说明】实现消息列表视图模型。
 *  1. 本视图模型负责从服务器拉取好友列表、好友请求并将相关数据加载。
 *  2. 同时本视图模型还会将好友按昵称首字母进行分组，从而帮助视图在界面右侧维护一个“字母表”方便快速检索好友。
 *
 * 【Module name】Message List View Model (TContactViewModel)
 * 【Function description】A view model that implements a message list.
 *  1. This view model is responsible for pulling friend lists, friend requests and loading related data from the server.
 *  2. At the same time, this view model will also group friends by the first latter of their nicknames, which helps the view maintain an "alphabet" on the right side of the interface to facilitate quick retrieval of friends.
 */
@interface TUIContactViewDataProvider : NSObject

/**
 *  数据字典，负责按姓名首字母归类好友信息（TCommonContactCellData）。
 *  例如，Jack 和 James 被存放在 “J”内。
 *
 *  Data dictionary, responsible for classifying friend information (TCommonContactCellData) by initials.
 *  For example, Jack and James are stored in "J".
 */
@property (readonly) NSDictionary<NSString *, NSArray<TUICommonContactCellData *> *> *dataDict;

/**
 *  分组列表，即当前好友的分组信息。
 *  例如，当前用户只有一个好友 “Jack”，则本列表中只有一个元素“J”。
 *  分组信息最多为 A - Z 的26个字母加上“#”。
 *
 *  The group list, that is, the group information of the current friend.
 *  For example, if the current user has only one friend "Jack", there is only one element "J" in this list.
 *  The grouping information is up to 26 letters from A - Z and "#".
 */
@property (readonly) NSArray *groupList;

/**
 *  加载完成标识符。
 *  YES：加载完成；NO：正在加载。
 *  通过该标识符，我们可以避免重复加载数据。
 *
 *  An identifier indicating whether the current loading process is complete
 *  YES: Loading is done; NO: Loading
 *  With this identifier, we can avoid reloading the data.
 */
@property (readonly) BOOL isLoadFinished;

/**
 *  未处理请求计数
 *  Count of pending friend requests
 */
@property (readonly) NSUInteger pendencyCnt;


- (void)loadContacts;

- (void)loadFriendApplication;

- (void)clearApplicationCnt;

@end

NS_ASSUME_NONNULL_END
