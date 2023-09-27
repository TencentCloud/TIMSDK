//
//  TUIChatPopMenu.h
//  TUIChat
//
//  Created by harvy on 2021/11/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIChatConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIChatPopMenuActionCallback)(void);

@interface TUIChatPopMenuAction : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, copy) TUIChatPopMenuActionCallback callback;

/**
 * 权重越大越靠前weight:  语音播放风格(11000) 复制 10000  转发 9000 多选 8000 引用 7000 回复 5000 撤回4000 删除 3000  翻译 2000
 * The higher the weight, the more prominent it is: audioPlayback 11000 Copy 10000, Forward 9000, Multiple Choice 8000, Quote 7000, Reply 5000, Withdraw 4000, Delete 3000.
 */
@property(nonatomic, assign) NSInteger weight;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image weight:(NSInteger)weight callback:(TUIChatPopMenuActionCallback)callback;
@end

typedef void (^TUIChatPopMenuHideCallback)(void);
@interface TUIChatPopMenu : UIView
@property(nonatomic, copy) TUIChatPopMenuHideCallback hideCallback;
@property(nonatomic, copy) void (^reactClickCallback)(NSString *faceName);

/**
 * TUIChatPopMenu 默认不带 emojiView。如果要显示，需要使用该方法初始化。
 * TUIChatPopMenu has no emojiView by default. If you need a chatPopMenu with emojiView, use this initializer.
 */
- (instancetype)initWithEmojiView:(BOOL)hasEmojiView frame:(CGRect)frame;

- (void)addAction:(TUIChatPopMenuAction *)action;
- (void)removeAllAction;
- (void)setArrawPosition:(CGPoint)point adjustHeight:(CGFloat)adjustHeight;
- (void)showInView:(UIView *__nullable)window;
- (void)layoutSubview;
- (void)hideWithAnimation;

@end

NS_ASSUME_NONNULL_END
