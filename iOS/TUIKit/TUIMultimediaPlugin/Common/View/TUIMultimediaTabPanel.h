// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMultimediaTabPanelTab;

@protocol TUIMultimediaTabPanelDelegate;

@interface TUIMultimediaTabPanel : UIView
@property(nonatomic) NSArray<TUIMultimediaTabPanelTab *> *tabs;
@property(nonatomic) NSInteger selectedIndex;
@property(weak, nullable, nonatomic) id<TUIMultimediaTabPanelDelegate> delegate;
- (id)initWithFrame:(CGRect)frame;
@end

@protocol TUIMultimediaTabPanelDelegate <NSObject>
- (void)tabPanel:(TUIMultimediaTabPanel *)panel selectedIndexChanged:(NSInteger)selectedIndex;
@end

@interface TUIMultimediaTabPanelTab : NSObject
@property(nonatomic) UIView *view;
@property(nullable, nonatomic) NSString *name;
@property(nullable, nonatomic) UIImage *icon;
- (instancetype)initWithName:(nullable NSString *)name icon:(nullable UIImage *)icon view:(UIView *)view;
@end

@protocol TUIMultimediaTabBarDelegate;

@interface TUIMultimediaTabBar : UIView
@property(nonatomic) NSArray<id> *tabs;
@property(nonatomic) NSInteger selectedIndex;
@property(weak, nullable, nonatomic) id<TUIMultimediaTabBarDelegate> delegate;
@end

@protocol TUIMultimediaTabBarDelegate <NSObject>
- (void)tabBar:(TUIMultimediaTabBar *)bar selectedIndexChanged:(NSInteger)index;
@end

@interface TUIMultimediaTabBarCell : UICollectionViewCell
@property(nullable, nonatomic) NSAttributedString *attributedText;
@property(nullable, nonatomic) UIImage *icon;
@property(nonatomic) CGFloat padding;
@property(nonatomic) BOOL barCellSelected;
+ (NSString *)reuseIdentifier;
@end

NS_ASSUME_NONNULL_END
