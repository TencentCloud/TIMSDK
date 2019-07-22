#import <UIKit/UIKit.h>

@class TPopView;
@protocol TPopViewDelegate <NSObject>
- (void)popView:(TPopView *)popView didSelectRowAtIndex:(NSInteger)index;
@end

@interface TPopView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGPoint arrowPoint;
@property (nonatomic, weak) id<TPopViewDelegate> delegate;
- (void)setData:(NSMutableArray *)data;
- (void)showInWindow:(UIWindow *)window;
@end
