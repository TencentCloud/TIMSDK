//
//  TUIChatPopContextExtionView.h
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/12/1.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatPopContextExtionItem : NSObject

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong) UIColor *titleColor;

@property(nonatomic, strong) UIFont *titleFont;

@property(nonatomic, assign) CGFloat weight;

@property(nonatomic, strong) UIImage *markIcon;

@property(nonatomic, assign) CGFloat itemHeight;

@property(nonatomic, assign) BOOL needBottomLine;

@property(nonatomic, copy) void (^actionHandler)(TUIChatPopContextExtionItem *item);

- (instancetype)initWithTitle:(NSString *)title markIcon:(UIImage *)markIcon weight:(NSInteger)weight withActionHandler:(void (^)(id action))actionHandler;

@end

@interface TUIChatPopContextExtionView : UIView

- (void)configUIWithItems:(NSMutableArray<TUIChatPopContextExtionItem *> *)items topBottomMargin:(CGFloat)topBottomMargin;

@end
NS_ASSUME_NONNULL_END
