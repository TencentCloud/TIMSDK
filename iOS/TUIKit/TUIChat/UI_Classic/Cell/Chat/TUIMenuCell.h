
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TUIMenuCellData.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIMenuCell
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIMenuCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *menu;

- (void)setData:(TUIMenuCellData *)data;

@end
