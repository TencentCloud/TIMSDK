
#import <UIKit/UIKit.h>

@interface UIImage (TUIDarkMode)

+ (void)d_fixResizableImage;

+ (UIImage *)d_imageWithImageLight:(NSString *)light dark:(NSString *)dark;

@end

