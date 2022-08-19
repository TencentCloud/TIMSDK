
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIMenuCellData
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIMenuCellData : NSObject

/**
 *  分组单元中分组缩略图的存取路径
 *  Access path for grouped thumbnails in grouping units
 */
@property (nonatomic, strong) NSString *path;

@property (nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
