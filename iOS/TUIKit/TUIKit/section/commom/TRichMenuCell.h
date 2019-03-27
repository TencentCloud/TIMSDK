//
//  TRichMenuCell.h
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 annidyfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRichMenuCellData.h"

@interface TRichMenuCell : UITableViewCell
{
@protected
    UILabel     *_desc;
    UILabel     *_value;
    
@protected
    UISwitch    *_onSwitch;
}

@property (nonatomic) TRichMenuCellData *data;
@property (nonatomic, readonly) UISwitch *onSwitch;


+ (NSInteger)heightOf:(TRichMenuCellData *)data;
- (void)doAction;

@end
