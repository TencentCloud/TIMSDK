//
//  TUIChatSmallTongue.h
//  TUIChat
//
//  Created by xiangzhang on 2022/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIChatDefine.h"

@class TUIChatSmallTongue;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIChatSmallTongueViewDelegate <NSObject>

- (void)onChatSmallTongueClick:(TUIChatSmallTongue *)tongue;

@end

@interface TUIChatSmallTongueView : UIView

@property(nonatomic, weak) id<TUIChatSmallTongueViewDelegate> delegate;

- (void)setTongue:(TUIChatSmallTongue *)tongue;

@end

@interface TUIChatSmallTongue : NSObject

@property(nonatomic, assign) TUIChatSmallTongueType type;
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, assign) NSInteger unreadMsgCount;
@property(nonatomic, strong) NSString *atTipsStr;
@property(nonatomic, strong) NSArray *atMsgSeqs;

@end

@interface TUIChatSmallTongueManager : NSObject

+ (void)showTongue:(TUIChatSmallTongue *)tongue delegate:(id<TUIChatSmallTongueViewDelegate>)delegate;
+ (void)removeTongue:(TUIChatSmallTongueType)type;
+ (void)removeTongue;
+ (void)hideTongue:(BOOL)isHidden;
+ (void)adaptTongueBottomMargin:(CGFloat)margin;

@end

NS_ASSUME_NONNULL_END
