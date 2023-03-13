/**
 *
 *  本文件声明用于实现黑名单页面的视图模型。
 *  视图模型负责承担界面中的部分数据处理和业务逻辑，如拉取黑名单信息，加载黑名单数据。
 *
 *  This file declares the view model used to implement the blocklist page.
 *  The view model is responsible for some data processing and business logic in the interface, such as pulling blacklist information and loading blocklist data.
 */

#import <Foundation/Foundation.h>
#import "TUICommonContactCell_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】黑名单界面视图模型（TUIBlackListViewModel）
 * 【功能说明】负责拉取用户的黑名单信息，并在页面中显示。
 *  视图模型同时负责将拉取到的信息进行加载，方便客户端内的数据处理。
 *
 * 【Module name】 TUIBlackListViewModel
 * 【Function description】It is responsible for pulling the user's blocklist information and displaying it on the page.
 *  The view model is also responsible for loading the pulled information to facilitate data processing in the client.
 */
@interface TUIBlackListViewDataProvider_Minimalist : NSObject

/**
 *  黑名单列表。
 *  黑名单列表中存放了被拉黑用户的详细信息。
 *  包括用户头像（URL 和图像）、用户 ID、用户昵称等详细信息。用于在您点击到详细见面时展示详细信息。
 *
 *  Bocklist data
 *  The blocklist stores the detailed information of the blocked users.
 *  Include details such as user avatar (URL and image), user ID, user nickname, etc. Used to display detailed information when you click to a detailed meeting.
 */
@property (readonly) NSArray<TUICommonContactCellData_Minimalist *> *blackListData;

@property (readonly) BOOL isLoadFinished;

- (void)loadBlackList;

@end

NS_ASSUME_NONNULL_END
