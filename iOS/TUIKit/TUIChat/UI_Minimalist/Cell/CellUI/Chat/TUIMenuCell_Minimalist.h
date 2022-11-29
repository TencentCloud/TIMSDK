#import <UIKit/UIKit.h>
#import "TUIMenuCellData_Minimalist.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIMenuCell_Minimalist
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIMenuCell_Minimalist : UICollectionViewCell

@property (nonatomic, strong) UIImageView *menu;

- (void)setData:(TUIMenuCellData_Minimalist *)data;

@end
