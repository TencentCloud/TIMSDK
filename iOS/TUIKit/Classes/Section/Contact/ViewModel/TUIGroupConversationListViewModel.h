/******************************************************************************
 *
 *  本文件声明了群列表界面的视图模型。
 *  视图模型负责通过 IM SDK 提供的接口拉取群列表数据并进行加载，方便页面对群列表进行展示。
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "TUIConversationCell.h"
#import "TCommonContactCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】群组列表视图模型（TUIGroupConversationListViewModel）
 * 【功能说明】负责拉取用户的所在的群组信息，并将获得数据进行加载。
 *  视图模型通过 IM SDK 提供的接口拉取用户所在的群组信息。并将群组信息按名称首字母分类存放。
 */
@interface TUIGroupConversationListViewModel : NSObject

/**
 *  群组分组。
 *  通过字典的方式进行分组。
 *  例如 TeaGroup 和 TennisGroup 都会被存放进 “T” 对应的分组。
 */
@property (readonly) NSDictionary<NSString *, NSArray<TCommonContactCellData *> *> *dataDict;

/**
 *  分组列表，即当前群组的分组信息。
 *  例如，当前用户只有一个群 TeaGroup，则本列表中只有一个元素“T”。
 *  分组信息最多为 A - Z 的26个字母加上“#”。
 */
@property (readonly) NSArray *groupList;

/**
 *  加载完成标识符。
 *  YES：加载完成；NO：正在加载。
 *  通过该标识符，我们可以避免重复加载数据。
 */
@property (readonly) BOOL isLoadFinished;


/**
 *  加载群组列表。
 *  本函数通过 IM SDK 中 TIMGroupManager 类提供的 getGroupList 接口拉取群组资料。
 *  对拉取的群组资料，将其加载为 TCommonContactCellData。
 *  同时，本函数对群名称进行分类，初始化 dataDict 以及 groupList。
 */
- (void)loadConversation;


/**
 *  移除选中群组。
 *  移除群组后，将会同时更新 dataDict 中的信息。
 *
 *  @param TCommonContactCellData 被移除的群组数据。
 */
- (void)removeData:(TCommonContactCellData *)data;

@end

NS_ASSUME_NONNULL_END
