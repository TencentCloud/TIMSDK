//
//  TCAudioScrollerMenuCell.h
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/27.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TCAudioScrollMenuCellModel;
@interface TCAudioScrollerMenuCell : UICollectionViewCell

- (void)setupCellWithModel:(TCAudioScrollMenuCellModel *)model;

@end

NS_ASSUME_NONNULL_END
