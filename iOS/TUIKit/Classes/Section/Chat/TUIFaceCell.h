/******************************************************************************
 *
 *  本文件声明用于实现表情单元的组件，即在您表情原则页面，负责显示单个表情的 UI 单元。
 *  TFaceCellData：用于存放表情的名称、本地存储路径。
 *  TUIFaceCell：用于存放表情的图像，并根据 TFaceCellData 初始化 Cell。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////////////////
//
//                             TFaceCellData
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIFaceCellData
 * 【功能说明】存储表情的名称、本地存储路径。
 */
@interface TFaceCellData : NSObject

/**
 *  表情名称。
 */
@property (nonatomic, strong) NSString *name;

/**
 * 表情的本地化名称（国际化属性，如果为空或者length为0，默认显示name）
 */
@property (nonatomic, copy) NSString *localizableName;

/**
 *  表情在本地缓存的存储路径。
 */
@property (nonatomic, strong) NSString *path;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIFaceCell
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIFaceCell
 * 【功能说明】存储表情的图像，并根据 TFaceCellData 初始化 Cell。
 *  在表情视图中，TUIFaceCell 即为界面显示的单元。
 */
@interface TUIFaceCell : UICollectionViewCell

/**
 *  表情图像
 *  表情所对应的Image图像。
 */
@property (nonatomic, strong) UIImageView *face;

/**
 *  设置表情单元的数据
 *
 *  @param data 需要设置的数据源。
 */
- (void)setData:(TFaceCellData *)data;
@end
