
@import UIKit;
#import "TUICameraMacro.h"

@class TUICameraViewController;
@protocol TUICameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithVideoURL:(NSURL *)url;
- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithImageData:(NSData *)data;
- (void)cameraViewControllerDidCancel:(TUICameraViewController *)controller;
@end


@interface TUICameraViewController : UIViewController

@property (nonatomic, weak) id<TUICameraViewControllerDelegate> delegate;

/// default TUICameraMediaTypePhoto
@property(nonatomic) TUICameraMediaType type;

/// previewView的宽高比, 默认TUICameraViewAspectRatio16x9
@property (nonatomic) TUICameraViewAspectRatio aspectRatio;

/// default 15s
@property (nonatomic) NSTimeInterval videoMaximumDuration;
/// default 3s
@property (nonatomic) NSTimeInterval videoMinimumDuration;

@end
