//
//  MenuView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMenuView;
@protocol TMenuViewDelegate <NSObject>
- (void)menuView:(TMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;
- (void)menuViewDidSendMessage:(TMenuView *)menuView;
@end

@interface TMenuView : UIView
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UICollectionView *menuCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *menuFlowLayout;
@property (nonatomic, weak) id<TMenuViewDelegate> delegate;
- (void)scrollToMenuIndex:(NSInteger)index;
- (void)setData:(NSMutableArray *)data;
@end
