/******************************************************************************
 *
 *  本文件声明了通讯录界面的视图模型。
 *  视图模型负责从服务器拉取好友列表、好友请求并将相关数据加载。
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "TCommonContactCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】消息列表视图模型（TContactViewModel）
 * 【功能说明】实现消息列表视图模型。
 *  本视图模型负责从服务器拉取好友列表、好友请求并将相关数据加载。
 *  同时本视图模型还会将好友按昵称首字母进行分组，从而帮助视图在界面右侧维护一个“字母表”方便快速检索好友。
 */
@interface TContactViewModel : NSObject

/**
 *  数据字典，负责按姓名首字母归类好友信息（TCommonContactCellData）。
 *  例如，Jack 和 James 被存放在 “J”内。
 */
@property (readonly) NSDictionary<NSString *, NSArray<TCommonContactCellData *> *> *dataDict;

/**
 *  分组列表，即当前好友的分组信息。
 *  例如，当前用户只有一个好友 “Jack”，则本列表中只有一个元素“J”。
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
 *  未处理请求计数
 *  用于在“新的联系人”后显示好友请求的计数。
 */
@property (readonly) NSUInteger pendencyCnt;

/**
 *  加载联系人列表。
 *  本函数通过 IM SDK 中 TIMFriendshipManager 类提供的 getFriendList 接口拉取好友资料。
 *  对拉取的好友资料，将其加载为 TCommonContactCellData。
 *  同时，本函数对好友姓名进行分类，初始化 dataDict 以及 groupList。
 */
- (void)loadContacts;

/**
 *  加载好友申请列表
 */
- (void)loadFriendApplication;

/**
 *  清空请求计数。
 *  本函数通过 IM SDK 的接口将请求设为已读并设置已读时间戳，同时将 pendencyCnt 置0。
 */
- (void)clearApplicationCnt;

@end

NS_ASSUME_NONNULL_END
