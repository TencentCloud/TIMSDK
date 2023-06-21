
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TUIMenuCellData_Minimalist.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIMenuCell_Minimalist
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIMenuCell_Minimalist : UICollectionViewCell

@property(nonatomic, strong) UIImageView *menu;

- (void)setData:(TUIMenuCellData_Minimalist *)data;

@end
