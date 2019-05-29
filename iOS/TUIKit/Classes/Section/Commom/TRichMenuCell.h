//
//  TRichMenuCell.h
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 annidyfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRichMenuCellData.h"

extern NSString *const kRichMenuCellReuseIdentifier;

@interface TRichMenuCell : UITableViewCell
{
@protected
    UILabel     *_desc;
    UILabel     *_value;
}

@property (nonatomic) TRichMenuCellData *data;
@property (nonatomic, readonly) UISwitch *onSwitch;

@end
