//
//  TRichCellMenuData.h
//  TUIKit
//
//  Created by annidyfeng on 2019/3/11.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TRichCellMenuDataType) {
    ERichCell_Text,                 // 普通的显示
    ERichCell_TextNext,             // 普通的显示，有下一步
    ERichCell_Switch,               // 开关
};


@class TRichMenuCellData;
@class TRichMenuCell;

typedef void (^TRichCellAction)(TRichMenuCellData *menu, TRichMenuCell *cell);

// 复杂的UI
@interface TRichMenuCellData : NSObject

@property (nonatomic, assign) TRichCellMenuDataType type;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *value;

@property (nonatomic, assign) BOOL switchValue;

@property (nonatomic, copy) TRichCellAction onSwitchAction;
@property (nonatomic, copy) TRichCellAction onSelectAction;

@property (nonatomic, assign) NSTextAlignment valueAlignment;

@property (nonatomic, assign) NSInteger margin;
@property (nonatomic, assign) NSInteger descWidth;
@property (nonatomic, assign) NSInteger valueWidth;

@property UIFont *descFont;
@property UIColor *descColor;

@property UIFont *valueFont;
@property UIColor *valueColor;


@property (weak) TRichMenuCell *assignCell;

@end
