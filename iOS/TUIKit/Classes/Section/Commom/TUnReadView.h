#import <UIKit/UIKit.h>

@interface TUnReadView : UIView
@property (nonatomic, strong) UILabel *unReadLabel;
- (void)setNum:(NSInteger)num;
@end
