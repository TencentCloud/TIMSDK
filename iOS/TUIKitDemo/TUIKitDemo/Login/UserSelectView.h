
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
IB_DESIGNABLE

@class UserSelectView;

@protocol UserSelectViewDelegate <NSObject>

@optional

- (void)optionView:(UserSelectView *)optionView selectedIndex:(NSInteger)selectedIndex;

@end

@interface UserSelectView : UIView
/**
 标题名
 */
@property (nonatomic, strong) IBInspectable NSString *title;

/**
 标题颜色
 */
@property (nonatomic, strong) IBInspectable UIColor *titleColor;

/**
 标题字体大小
 */
@property (nonatomic, assign) IBInspectable CGFloat titleFontSize;

/**
 视图圆角
 */
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

/**
 视图边框颜色
 */
@property (nonatomic, strong) IBInspectable UIColor *borderColor;

/**
 边框宽度
 */
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

/**
 cell高度
 */
@property (nonatomic, assign) CGFloat rowHeigt;

/**
 数据源
 */
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, weak) id<UserSelectViewDelegate> delegate;

@property (nonatomic,copy) void(^selectedBlock)(UserSelectView *optionView,NSInteger selectedIndex);

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)dataSource;

@end

NS_ASSUME_NONNULL_END
