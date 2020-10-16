//
//  TUILiveTopSegmentView.h
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUILiveTopSegmentView;
@protocol TUILiveTopSegmentViewDelegate <NSObject>

- (void)topSegmentView:(TUILiveTopSegmentView *)view didClickIndex:(NSInteger)index;

@end

@interface TUILiveTopSegmentView : UIView

/// 点击事件的交互回调
@property(nonatomic, weak)id<TUILiveTopSegmentViewDelegate> delegate;
@property(nonatomic, strong)UIColor *tinColor;
@property(nonatomic, readonly)NSInteger currentIndex;

/// 设置选中的按钮
/// @param index 按钮下标，从0开始
-(void)setSelectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
