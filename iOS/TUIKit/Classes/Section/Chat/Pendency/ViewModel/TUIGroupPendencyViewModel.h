#import <Foundation/Foundation.h>
@class TUIGroupPendencyCellData;

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】TUIGroupPendencyViewModel
 * 【功能说明】群组请求视图模型
 *  本视图模型负责统一处理群组请求的消息。比如获取未读计数，接收新的请求消息并进行更新，在已有数据队列中同意/移除数据等一系列逻辑。
 *  
 */
@interface TUIGroupPendencyViewModel : NSObject

/**
 *  请求数据列表
 *  该列表中存放的对象类型为 TUIGroupPendencyCellData。
 *  即本数组中存放了当前群所有的待处理请求数据，且本属性为只读，不允许修改。
 */
@property (readonly) NSArray *dataList;

/**
 *  是否具有下一个请求数据。
 *  加载数据时，当前群组的请求列表还有未读取出时，hasNextData 为 YES。
 */
@property BOOL hasNextData;

/**
 *  加载标识符
 *  当前视图模型正在加载数据时，本属性为 YES，此时不允许再次加载，直至当前加载过程完成。
 */
@property BOOL isLoading;

/**
 *  未读计数
 *  即当前群组请求的未处理数目。
 */
@property int unReadCnt;

/**
 *  群组 ID
 *  用于识别当前群组，判定入群请求是否是针对本群组的请求。
 */
@property NSString *groupId;

/**
 *  加载数据
 *  1、先判断当前是否在加载，如果是，则终止本次加载。
 *  2、通过 IM SDK 中的 TIMGroupManager 类提供的 getPendencyFromServer 接口从服务器拉取请求数据，默认一页100个请求。
 *  3、对于拉取的数据，判定请求对应的群组 ID 是否与本群相同，若相同，则将该请求转换为 TUIGroupPendencyCellData 并存入 datalist。（从服务器拉取的请求对象为 TIMGroupPendencyItem）。
 */
- (void)loadData;

/**
 *  批准当前请求数据。
 *  本函数直接调用 TUIGroupPendencyCellData 中实现的 accept，同时未读计数减1。
 */
- (void)acceptData:(TUIGroupPendencyCellData *)data;

/**
 *  拒绝当前请求数据。
 *  将参数中的 data 从 datalist 中移除，并调用 TUIGroupPendencyCellData 中实现的 reject，同时未读计数减1。
 */
- (void)removeData:(TUIGroupPendencyCellData *)data;

@end

NS_ASSUME_NONNULL_END
