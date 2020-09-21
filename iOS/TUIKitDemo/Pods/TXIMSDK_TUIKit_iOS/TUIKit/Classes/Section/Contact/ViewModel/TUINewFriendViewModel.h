/******************************************************************************
 *
 *  本文件声明了好友申请界面的视图模型。
 *  视图模型可以通过 IM SDK 提供的接口拉取好友申请信息，并将拉取到的信息进行加载，便于好友申请界面的进一步显示。
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "TCommonPendencyCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】好友申请视图模型（TUINewFriendViewModel）
 * 【功能说明】负责拉取用户接收的好友申请，并将获得数据进行加载。
 *  视图模型通过 IM SDK 提供的接口拉取好友申请信息，并将拉取到的信息进行加载，便于好友申请界面的进一步显示。
 */
@interface TUINewFriendViewModel : NSObject

/**
 *  数据列表，存放用户收到的好友申请数据。
 *  本数组中存档的对象类为 TCommonPendencyCellData。
 */
@property (readonly) NSArray *dataList;

/**
 *  是否具有未显示的数据。
 *  YES：有未显示的请求；NO：所有请求已加载完毕。
 *  此位的声明，可以在请求过多时，分批拉取分批显示。
 */
@property BOOL hasNextData;

/**
 *  加载完成标识符。
 *  YES：加载完成；NO：正在加载。
 *  通过该标识符，我们可以避免重复加载数据。
 */
@property BOOL isLoading;

/**
 *  加载数据
 *  本函数通过 IM SDK 中的 TIMFriendshipManager 类提供的 getPendencyList 获取请求列表，并加载为 TCommonPendencyCellData 存入 dataList 中。
 */
- (void)loadData;

/**
 *  移除相应的请求。
 *  从 dataList 中移除相应 data，同时通过 IM SDK 在服务端删除对应请求。
 *
 *  @param data 需要移除的请求的数据。
 */
- (void)removeData:(TCommonPendencyCellData *)data;
- (void)agreeData:(TCommonPendencyCellData *)data;
@end

NS_ASSUME_NONNULL_END
