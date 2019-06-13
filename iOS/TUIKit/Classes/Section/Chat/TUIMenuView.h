//
//  MenuView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUIMenuView;
@protocol TMenuViewDelegate <NSObject>
- (void)menuView:(TUIMenuView *)menuView didSelectItemAtIndex:(NSInteger)index;
- (void)menuViewDidSendMessage:(TUIMenuView *)menuView;
@end

@interface TUIMenuView : UIView
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UICollectionView *menuCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *menuFlowLayout;
@property (nonatomic, weak) id<TMenuViewDelegate> delegate;
- (void)scrollToMenuIndex:(NSInteger)index;
- (void)setData:(NSMutableArray *)data;
@end
