//
//  UIViewAdditions.h
//

#import <UIKit/UIKit.h>

#define kScaleX [UIScreen mainScreen].bounds.size.width / 375
#define kScaleY [UIScreen mainScreen].bounds.size.height / 667

CG_INLINE CGRect CGRectMake_Auto(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
    const CGFloat xScale = [UIScreen mainScreen].bounds.size.width / 375;
    const CGFloat yScale = [UIScreen mainScreen].bounds.size.height / 667;
    
    CGRect rect;
    rect.origin.x = x * xScale;
    rect.origin.y = y * yScale;
    rect.size.width = width * xScale;
    rect.size.height = height * yScale;
    
    return rect;
}


@interface UIView (Additions)

- (void)removeAllSubViews;
- (void)setBackgroundImage:(UIImage*)image;
- (UIImage*)toImage;
- (UIViewController *)tx_viewController;
- (void)tx_observeKeyboardOnChange:(void(^)(CGFloat keyboardTop, CGFloat height))changeHandler;

// Position of the top-left corner in superview's coordinates
@property CGPoint position;
@property CGFloat x;
@property CGFloat y;
@property CGFloat top;
@property CGFloat bottom;
@property CGFloat left;
@property CGFloat right;


// makes hiding more logical
@property BOOL	visible;


// Setting size keeps the position (top-left corner) constant
@property CGSize size;
@property CGFloat width;
@property CGFloat height;

@end

@interface UIImageView (MFAdditions)

- (void) setImageWithName:(NSString *)name;

@end
