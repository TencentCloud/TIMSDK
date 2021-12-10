//
//  TButtonCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUICommonModel.h"



typedef enum : NSUInteger {
    ButtonGreen,
    ButtonWhite,
    ButtonRedText,
    ButtonBule,
} TUIButtonStyle;

@interface TUIButtonCellData : TUICommonCellData
@property (nonatomic, strong) NSString *title;
@property SEL cbuttonSelector;
@property TUIButtonStyle style;
@property (nonatomic, strong) UIColor *textColor;
@end

@interface TUIButtonCell : TUICommonTableViewCell
@property (nonatomic, strong) UIButton *button;
@property TUIButtonCellData *buttonData;

- (void)fillWithData:(TUIButtonCellData *)data;
@end
