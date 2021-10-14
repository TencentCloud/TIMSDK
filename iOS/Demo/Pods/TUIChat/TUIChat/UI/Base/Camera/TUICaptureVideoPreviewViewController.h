
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICaptureVideoPreviewViewController : UIViewController

@property (nonatomic) void (^commitBlock)(void);
@property (nonatomic) void (^cancelBlock)(void);

- (instancetype)initWithVideoURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
