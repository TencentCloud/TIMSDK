//
//  TUIFaceSegementScrollView.h
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/11/15.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIFaceView.h"
#import "TUIFaceVerticalView.h"
NS_ASSUME_NONNULL_BEGIN
@class TUIFaceGroup;

@interface TUIFaceSegementScrollView : UIView
@property(nonatomic, copy) void(^onScrollCallback)(NSInteger indexPage);
@property(strong, nonatomic) UIScrollView *pageScrollView;
- (void)setItems:(NSArray<TUIFaceGroup *> *)items delegate:(id <TUIFaceVerticalViewDelegate>) delegate;
- (void)updateContainerView;
- (void)setPageIndex:(NSInteger)index;
- (void)setAllFloatCtrlViewAllowSendSwitch:(BOOL)isAllow;
- (void)updateRecentView;
@end

NS_ASSUME_NONNULL_END
