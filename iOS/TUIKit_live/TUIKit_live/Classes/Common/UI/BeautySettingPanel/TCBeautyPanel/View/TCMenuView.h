// Copyright (c) 2019 Tencent. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TCMenuItem <NSObject>
- (NSString *)title;
- (UIImage *)icon;
@end

@protocol TCMenuViewDelegate, TCMenuViewDataSource;

@interface TCMenuView : UIView
@property (weak, nullable, nonatomic) id<TCMenuViewDelegate> delegate;
@property (weak, nullable, nonatomic) id<TCMenuViewDataSource> dataSource;

/// 被选中一级菜单的数组下标
@property (readonly, nonatomic) NSInteger menuIndex;

/// 被选中二级菜单的数组下标
@property (readonly, nonatomic) NSInteger optionIndex;

/// 菜单文字的标题颜色
@property (strong, nonatomic) UIColor *menuTitleColor;

/// 菜单文字的最小宽度
@property (assign, nonatomic) CGFloat minMenuWidth;

/// 二级菜单文字的最小宽度
@property (assign, nonatomic) CGFloat minSubMenuWidth;

/// 一级菜单背景色
@property (strong, nonatomic) UIColor *menuBackgroundColor;

/// 一级菜单选中后的背景图片
@property (strong, nonatomic, nullable) UIImage *menuSelectionBackgroundImage;

/// 二级菜单背景色
@property (strong, nonatomic) UIColor *subMenuBackgroundColor;

/// 二级菜单选中时标题的颜色
@property (strong, nonatomic, nullable) UIColor *subMenuSelectionColor;


- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(id<TCMenuViewDataSource>)dataSource;
- (void)setSelectedOption:(NSInteger)optionIndex inMenu:(NSInteger)menuIndex;
- (void)reloadData;
@end

@protocol TCMenuViewDelegate
- (void)menu:(TCMenuView *)menu didChangeToIndex:(NSInteger)menuIndex option:(NSInteger)optionIndex;
@end

@protocol TCMenuViewDataSource
- (NSInteger)numberOfMenusInMenu:(TCMenuView *)menu;
- (NSString *)titleOfMenu:(TCMenuView *)menu atIndex:(NSInteger)index;
- (NSUInteger)numberOfOptionsInMenu:(TCMenuView *)menu menuIndex:(NSInteger)index;
- (id<TCMenuItem>)menu:(TCMenuView *)menu
           itemAtMenuIndex:(NSInteger)index
               optionIndex:(NSInteger)optionIndex;
@end
NS_ASSUME_NONNULL_END
