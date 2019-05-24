//
//  MoreView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/21.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMoreView;
@protocol TMoreViewDelegate <NSObject>
- (void)moreView:(TMoreView *)moreView didSelectMoreAtIndex:(NSInteger)index;
@end

@interface TMoreView : UIView
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UICollectionView *moreCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *moreFlowLayout;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak) id<TMoreViewDelegate> delegate;
- (void)setData:(NSMutableArray *)data;
@end
