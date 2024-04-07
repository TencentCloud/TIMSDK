//
//  TUIChatPopMenu.h
//  TUIChat
//
//  Created by harvy on 2021/11/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIChatConfig.h"
#import "TUIChatPopMenuDefine.h"
#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIChatPopMenuActionCallback)(void);

@interface TUIChatPopMenuAction : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, copy) TUIChatPopMenuActionCallback callback;

/**
 * The higher the weight, the more prominent it is: audioPlayback 11000 Copy 10000, Forward 9000, Multiple Choice 8000, Quote 7000, Reply 5000, Withdraw 4000, Delete 3000.
 */
@property(nonatomic, assign) NSInteger weight;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image weight:(NSInteger)weight callback:(TUIChatPopMenuActionCallback)callback;
@end

typedef void (^TUIChatPopMenuHideCallback)(void);
@interface TUIChatPopMenu : UIView
@property(nonatomic, copy) TUIChatPopMenuHideCallback hideCallback;
@property(nonatomic, copy) void (^reactClickCallback)(NSString *faceName);
@property(nonatomic, weak) TUIMessageCellData *targetCellData;
/**
 * TUIChatPopMenu has no emojiView by default. If you need a chatPopMenu with emojiView, use this initializer.
 */
- (instancetype)initWithEmojiView:(BOOL)hasEmojiView frame:(CGRect)frame;

@property(nonatomic, strong, readonly) UIView *emojiContainerView;
@property(nonatomic, strong, readonly) UIView *containerView;

- (void)addAction:(TUIChatPopMenuAction *)action;
- (void)removeAllAction;
- (void)setArrawPosition:(CGPoint)point adjustHeight:(CGFloat)adjustHeight;
- (void)showInView:(UIView *__nullable)window;
- (void)layoutSubview;
- (void)hideWithAnimation;

@end

NS_ASSUME_NONNULL_END
