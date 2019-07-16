/******************************************************************************
 *
 *  本文件声明了好友选择界面的视图模型
 *  视图模型负责通过 IM SDK 的接口拉取好友数据，并将数据进行加载。
 *
 ******************************************************************************/
#import <Foundation/Foundation.h>
@class TCommonContactSelectCellData;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ContactSelectFilterBlock)(TCommonContactSelectCellData *data);

/**
 * 【模块名称】好友选择界面视图模型（TContactSelectViewModel）
 * 【功能说明】实现好友选择界面视图模型。
 *  本视图模型负责从服务器拉取好友列表、好友请求并将相关数据加载。
 *  同时本视图模型还会将好友按昵称首字母进行分组，从而帮助视图在界面右侧维护一个“字母表”方便快速检索好友。
 */
@interface TContactSelectViewModel : NSObject

/**
 *  数据字典，负责按姓名首字母归类好友信息（TCommonContactCellData）。
 *  例如，Jack 和 James 被存放在 “J”内。
 */
@property (readonly) NSDictionary<NSString *, NSArray<TCommonContactSelectCellData *> *> *dataDict;

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
 * 禁用联系人过滤器
 */
@property (copy) ContactSelectFilterBlock disableFilter;

/**
 * 显示联系人过滤器
 */
@property (copy) ContactSelectFilterBlock avaliableFilter;



- (void)loadContacts;

- (void)setSourceIds:(NSArray<NSString *> *)ids;

@end

NS_ASSUME_NONNULL_END
