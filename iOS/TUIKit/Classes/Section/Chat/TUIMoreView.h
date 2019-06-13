//
//  MoreView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/21.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIInputMoreCell.h"

@class TUIMoreView;
@protocol TMoreViewDelegate <NSObject>
- (void)moreView:(TUIMoreView *)moreView didSelectMoreCell:(TUIInputMoreCell *)cell;
@end

@interface TUIMoreView : UIView
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UICollectionView *moreCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *moreFlowLayout;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak) id<TMoreViewDelegate> delegate;
- (void)setData:(NSArray *)data;
@end
