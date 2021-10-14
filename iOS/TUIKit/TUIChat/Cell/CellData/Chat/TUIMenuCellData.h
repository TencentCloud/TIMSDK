
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIMenuCellData
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIMenuCellData
 * 【功能说明】用于存放 MenuCell 的图像路径、选择状态位等 MenuCell 所需的信息与数据。
 */
@interface TUIMenuCellData : NSObject

/**
 *  分组单元中分组缩略图的存取路径
 */
@property (nonatomic, strong) NSString *path;

/**
 *  选择标志位
 *  根据选择状态不同显示不同的图标状态
 */
@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
