#import <UIKit/UIKit.h>

@interface TAddCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *headImageView;
- (void)setImage:(NSString *)image;
+ (CGSize)getSize;
@end
