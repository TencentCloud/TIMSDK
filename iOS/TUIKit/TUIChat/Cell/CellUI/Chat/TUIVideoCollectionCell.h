/******************************************************************************
 *
 *  本文件声明了两个类，TUIMenuCellData 和 TUIMenuCell 用于实现表情菜单视图中的单个表情单元。
 *  表情菜单视图，即在表情视图最下方的亮白色视图，负责显示各个表情分组及其缩略图，并提供“发送”按钮。
 *  本文件包含的两个类的功能简述：
 *  TUIMenuCellData：存储表情菜单缩略图的本地存储路径，同时包含其选择标志位（isSelected）。
 *  TUIMenuCell：存储表情菜单的图像，并根据 TUIMenuCellData 初始化 Cell。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIMediaCollectionCell.h"
#import "TUIVideoMessageCellData.h"

/**
 * 【模块名称】TUIMediaVideoCell
 */
@interface TUIVideoCollectionCell : TUIMediaCollectionCell
/**
 *  填充数据
 *  根据 data 设置视频消息的数据。
 *
 *  @param data 填充数据需要的数据源
 */
- (void)fillWithData:(TUIVideoMessageCellData *)data;

/**
 *  停止视频播放和本地保存
 */
- (void)stopVideoPlayAndSave;
@end
