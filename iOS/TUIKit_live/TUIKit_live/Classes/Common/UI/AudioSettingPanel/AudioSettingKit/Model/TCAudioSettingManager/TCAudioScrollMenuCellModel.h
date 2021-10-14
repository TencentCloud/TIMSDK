//
//  TCAudioScrollMenuCellModel.h
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CellAction)(void);

@interface TCAudioScrollMenuCellModel : NSObject

@property (nonatomic, assign) NSInteger actionID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIImage *selectedIcon;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, copy)CellAction action;

@end

NS_ASSUME_NONNULL_END
