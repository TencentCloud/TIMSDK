//
//  TUIChatSmallTongue.h
//  TUIChat
//
//  Created by xiangzhang on 2022/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIChatDefine.h"

@import UIKit;

@class TUIChatSmallTongue_Minimalist;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIChatSmallTongueViewDelegate_Minimalist <NSObject>

- (void)onChatSmallTongueClick:(TUIChatSmallTongue_Minimalist *)tongue;

@end

@interface TUIChatSmallTongueView_Minimalist : UIView

@property(nonatomic, weak) id<TUIChatSmallTongueViewDelegate_Minimalist> delegate;

- (void)setTongue:(TUIChatSmallTongueView_Minimalist *)tongue;

@end

@interface TUIChatSmallTongue_Minimalist : NSObject

@property(nonatomic, assign) TUIChatSmallTongueType type;
@property(nonatomic, strong) UIView *parentView;
@property(nonatomic, assign) uint64_t unreadMsgCount;
@property(nonatomic, strong) NSArray *atMsgSeqs;

@end

@interface TUIChatSmallTongueManager_Minimalist : NSObject

+ (void)showTongue:(TUIChatSmallTongue_Minimalist *)tongue delegate:(id<TUIChatSmallTongueViewDelegate_Minimalist>)delegate;
+ (void)removeTongue:(TUIChatSmallTongueType)type;
+ (void)removeTongue;
+ (void)hideTongue:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
