//
//  TUIChatPopMenu.h
//  TUIChat
//
//  Created by harvy on 2021/11/30.
//

#import <UIKit/UIKit.h>
#import "TUIChatConfig.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIChatPopMenuActionCallback)(void);

@interface TUIChatPopMenuAction : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) TUIChatPopMenuActionCallback callback;

/**
 * 排序优先级:  复制(1)、转发(2)、多选(3)、引用(4)、回复(5)、撤回(6)、删除(7)
 * Sort priorities: copy, forward, multiselect, reference, reply, Withdraw, delete
 */
@property (nonatomic, assign) NSInteger rank;

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                         rank:(NSInteger)rank
                     callback:(TUIChatPopMenuActionCallback)callback;
@end


typedef void(^TUIChatPopMenuHideCallback)(void);
@interface TUIChatPopMenu : UIView
@property (nonatomic, copy) TUIChatPopMenuHideCallback hideCallback;
@property (nonatomic, copy) void(^reactClickCallback)(NSString *faceName);

/**
 * TUIChatPopMenu 默认不带 emojiView。如果要显示，需要使用该方法初始化。
 * TUIChatPopMenu has no emojiView by default. If you need a chatPopMenu with emojiView, use this initializer.
 */
- (instancetype)initWithEmojiView:(BOOL)hasEmojiView frame:(CGRect)frame;

- (void)addAction:(TUIChatPopMenuAction *)action;
- (void)removeAllAction;
- (void)setArrawPosition:(CGPoint)point adjustHeight:(CGFloat)adjustHeight;
- (void)showInView:(UIView * __nullable)window;
- (void)layoutSubview;
- (void)hideWithAnimation;

@end

NS_ASSUME_NONNULL_END
