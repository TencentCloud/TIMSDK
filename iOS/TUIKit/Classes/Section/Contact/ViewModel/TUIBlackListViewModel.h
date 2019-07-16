/******************************************************************************
 *
 *  本文件声明用于实现黑名单页面的视图模型。
 *  视图模型负责承担界面中的部分数据处理和业务逻辑，如拉取黑名单信息，加载黑名单数据。
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "TCommonContactCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】黑名单界面视图模型（TUIBlackListViewModel）
 * 【功能说明】负责拉取用户的黑名单信息，并在页面中显示。
 *  视图模型同时负责将拉取到的信息进行加载，方便客户端内的数据处理。
 */
@interface TUIBlackListViewModel : NSObject

/**
 *  黑名单列表。
 *  黑名单列表中存放了被拉黑用户的详细信息。
 *  包括用户头像（URL 和图像）、用户 ID、用户昵称等详细信息。用于在您点击到详细见面时展示详细信息。
 */
@property (readonly) NSArray<TCommonContactCellData *> *blackListData;

/**
 *  加载完成标识符。
 *  YES：加载完成；NO：正在加载。
 *  通过该标识符，我们可以避免重复加载数据。
 */
@property (readonly) BOOL isLoadFinished;

/**
 *  加载黑名单。
 *  本函数通过调用 IM SDK 中的 TIMFriendManager 类提供的 getBlackList 接口拉取黑名单信息。
 *  然后将拉取的黑名单信息加载为 TCommonContactCellData，方便客户端的进一步管理。
 */
- (void)loadBlackList;

@end

NS_ASSUME_NONNULL_END
