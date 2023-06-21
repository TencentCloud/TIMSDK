
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

@import UIKit;
#import "TUICameraMacro.h"

@class TUICameraViewController;
@protocol TUICameraViewControllerDelegate <NSObject>

- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithVideoURL:(NSURL *)url;
- (void)cameraViewController:(TUICameraViewController *)controller didFinishPickingMediaWithImageData:(NSData *)data;
- (void)cameraViewControllerDidCancel:(TUICameraViewController *)controller;
- (void)cameraViewControllerDidPictureLib:(TUICameraViewController *)controller finishCallback:(void (^)(void))callback;
@end

@interface TUICameraViewController : UIViewController

@property(nonatomic, weak) id<TUICameraViewControllerDelegate> delegate;

/// default TUICameraMediaTypePhoto
@property(nonatomic) TUICameraMediaType type;

/// default TUICameraViewAspectRatio16x9
@property(nonatomic) TUICameraViewAspectRatio aspectRatio;

/// default 15s
@property(nonatomic) NSTimeInterval videoMaximumDuration;
/// default 3s
@property(nonatomic) NSTimeInterval videoMinimumDuration;

@end
