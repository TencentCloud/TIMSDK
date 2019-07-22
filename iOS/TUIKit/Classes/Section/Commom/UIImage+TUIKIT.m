#import "UIImage+TUIKIT.h"
#import "THeader.h"

@implementation UIImage (TUIKIT)

+ (UIImage *)tk_imageNamed:(NSString *)name
{
    return [UIImage imageNamed:TUIKitResource(name)];
}

@end
