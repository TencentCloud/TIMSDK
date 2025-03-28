//
//  TUIReactPreviewCell.h
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TUIReactModel;
#define MaxTagSize [UIScreen mainScreen].bounds.size.width * 0.25 * 3 - 20

NS_ASSUME_NONNULL_BEGIN

@interface TUIReactPreviewCell : UIView

@property(nonatomic, strong) TUIReactModel *model;

@property(nonatomic, assign) CGFloat ItemWidth;
@property(nonatomic, copy) void (^emojiClickCallback)(TUIReactModel *model);
@property(nonatomic, copy) void (^userClickCallback)(TUIReactModel *model);
@end

NS_ASSUME_NONNULL_END
