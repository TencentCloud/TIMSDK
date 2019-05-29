//
//  TIndexView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 代理方法 */
@protocol TAddIndexViewDelegate <NSObject>

@required
/** 当前选中下标 */
- (void)selectedSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
/** 添加指示器视图 */
- (void)addIndicatorView:(UIView *)view;

@end

/** 数据源方法 */
@protocol TAddIndexViewDataSource <NSObject>

/** 组标题数组 */
- (NSArray<NSString *> *)sectionIndexTitles;

@end

@interface TAddIndexView : UIControl <CAAnimationDelegate>

@property (nonatomic, weak, nullable) id<TAddIndexViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<TAddIndexViewDataSource> dataSource;

@property (nonatomic, assign) CGFloat titleFontSize;                                    /**< 字体大小 */
@property (nonatomic, strong, nullable) UIColor * titleColor;                           /**< 字体颜色 */
@property (nonatomic, assign) CGFloat marginRight;                                      /**< 右边距 */
@property (nonatomic, assign) CGFloat titleSpace;                                       /**< 文字间距 */
@property (nonatomic, assign) CGFloat indicatorMarginRight;                             /**< 指示器视图距离右侧的偏移量 */
//设置 --> 声音与触感 --> 系统触感反馈打开
@property (nonatomic, assign) BOOL vibrationOn;                                         /**< 开启震动反馈 (iOS10及以上) */
@property (nonatomic, assign) BOOL searchOn;                                            /**< 开启搜索功能  */

- (void)setSelectionIndex:(NSInteger)index;                                             /** 设置当前选中组 */
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end
