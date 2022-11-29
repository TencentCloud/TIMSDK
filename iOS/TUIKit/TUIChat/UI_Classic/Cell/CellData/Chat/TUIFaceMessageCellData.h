/**
 *
 *  本文件声明了 TUIFaceMessageCellData 类。
 *  本类继承于 TUIMessageCellData，用于存放表情消息单元所需的一系列数据与信息。
 *
 *  This file declares the TUIFaceMessageCellData class.
 *  This class inherits from TUIMessageCellData and is used to store a series of data and information required by the emoticon message unit.
 */
#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 【模块名称】TUIFaceMessageCellData
 * 【功能说明】表情消息单元数据源。
 *  表情消息单元，即显示动画表情时所使用并展示的消息单元。
 *  表情消息单元数据源，则是为表情消息单元的显示提供一系列所需数据的类。
 *
 * 【Module name】TUIFaceMessageCellData
 * 【Function description】Emoticon message unit data source.
 *  - The emoticon message unit is the message unit used and displayed when displaying animated emoticons.
 *  - The emoticon message unit data source is a class that provides a series of required data for the display of the emoticon message unit.
*/
@interface TUIFaceMessageCellData : TUIBubbleMessageCellData

/**
 *  表情分组索引
 *  即表情所在分组的下标，用于定位表情所在表情组。
 *
 *  The index of emoticon groups
 *  - The subscript of the group where the emoticon is located, which is used to locate the emoticon group where the emoticon is located.
 */
@property (nonatomic, assign) NSInteger groupIndex;

/**
 *  表情所在路径
 *
 *  The path of the emoticon file
 */
@property (nonatomic, strong) NSString *path;

/**
 *  表情名称
 *
 *  The name of emoticon.
 */
@property (nonatomic, strong) NSString *faceName;

@end

NS_ASSUME_NONNULL_END
