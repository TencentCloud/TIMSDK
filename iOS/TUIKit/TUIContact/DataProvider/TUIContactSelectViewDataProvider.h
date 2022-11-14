/**
 *
 *  本文件声明了好友选择界面的视图模型
 *  视图模型负责通过 IM SDK 的接口拉取好友数据，并将数据进行加载。
 *
 *  This file declares the view model for the friend selection interface
 *  The view model is responsible for pulling friend data through the IM SDK interface and loading the data.
 */
#import <Foundation/Foundation.h>
@class TUICommonContactSelectCellData;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ContactSelectFilterBlock)(TUICommonContactSelectCellData *data);

/**
 * 【模块名称】好友选择界面视图模型（TContactSelectViewModel）
 * 【功能说明】实现好友选择界面视图模型。
 *  本视图模型负责从服务器拉取好友列表、好友请求并将相关数据加载。
 *  同时本视图模型还会将好友按昵称首字母进行分组，从而帮助视图在界面右侧维护一个“字母表”方便快速检索好友。
 *
 * 【Module name】Friend selection interface view model (TContactSelectViewModel)
 * 【Function description】Implement the friend selection interface view model.
 *  This view model is responsible for pulling friend lists, friend requests and loading related data from the server.
 *  At the same time, this view model will also group friends according to the initials of their nicknames, which helps the view maintain an "alphabet" on the right side of the interface to quickly retrieve friends.
 */
@interface TUIContactSelectViewDataProvider : NSObject

/**
 *  数据字典，负责按姓名首字母归类好友信息（TCommonContactCellData）。
 *  例如，Jack 和 James 被存放在 “J”内。
 *
 *  Data dictionary, responsible for classifying friend information (TCommonContactCellData) by initials.
 *  For example, Jack and James are stored in "J".
 */
@property (readonly) NSDictionary<NSString *, NSArray<TUICommonContactSelectCellData *> *> *dataDict;

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
 * 禁用联系人过滤器
 * Filter to disable contacts
 */
@property (copy) ContactSelectFilterBlock disableFilter;

/**
 * 显示联系人过滤器
 * Filter to display contacts
 */
@property (copy) ContactSelectFilterBlock avaliableFilter;

- (void)loadContacts;

- (void)setSourceIds:(NSArray<NSString *> *)ids;
- (void)setSourceIds:(NSArray<NSString *> *)ids displayNames:(NSDictionary * __nullable)displayNames;

@end

NS_ASSUME_NONNULL_END
