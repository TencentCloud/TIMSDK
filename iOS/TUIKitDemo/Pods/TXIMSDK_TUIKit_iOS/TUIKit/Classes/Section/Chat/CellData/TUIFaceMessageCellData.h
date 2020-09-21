/******************************************************************************
 *
 *  本文件声明了 TUIFaceMessageCellData 类。
 *  本类继承于 TUIMessageCellData，用于存放表情消息单元所需的一系列数据与信息。
 *
 ******************************************************************************/
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/**
* 【模块名称】TUIFaceMessageCellData
* 【功能说明】表情消息单元数据源。
*  表情消息单元，即显示动画表情时所使用并展示的消息单元。
*  表情消息单元数据源，则是为表情消息单元的显示提供一系列所需数据的类。
*  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
*/
@interface TUIFaceMessageCellData : TUIMessageCellData

/**
 *  表情分组索引
 *  即表情所在分组的下标，用于定位表情所在表情组。
 */
@property (nonatomic, assign) NSInteger groupIndex;

/**
 *  表情所在路径
 */
@property (nonatomic, strong) NSString *path;

/**
 *  表情名称
 */
@property (nonatomic, strong) NSString *faceName;

@end

NS_ASSUME_NONNULL_END
