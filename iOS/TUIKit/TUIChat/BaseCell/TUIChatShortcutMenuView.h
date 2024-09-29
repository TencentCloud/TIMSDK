//
//  TUIChatShortcutMenuView.h
//  TUIChat
//
//  Created by Tencent on 2023/6/29.
//  Copyright © 2024 Tencent. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatShortcutMenuCellData : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) SEL cselector;
@property (nonatomic, strong) id target;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;

- (CGSize)calcSize;
@end


@interface TUIChatShortcutMenuCell : UICollectionViewCell
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) TUIChatShortcutMenuCellData *cellData;
@end


@interface TUIChatShortcutMenuView : UIView
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat itemHorizontalSpacing;
- (instancetype)initWithDataSource:(NSArray *)source;
- (void)updateFrame;
@end

NS_ASSUME_NONNULL_END
