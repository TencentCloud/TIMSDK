//
//  TCAudioScrollMenuView.h
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TCAudioScrollMenuCellModel;
@interface TCAudioScrollMenuView : UIView

@property(nonatomic, strong)NSString* title;
@property(nonatomic, strong)NSArray<TCAudioScrollMenuCellModel *> *dataSource;

@end

NS_ASSUME_NONNULL_END
