//
//  TUILiveUtil.h
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define IPHONE_X \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

@interface TUILiveUtil : NSObject
+ (float)heightForString:(UITextView *)textView andWidth:(float)width;
+ (void)toastTip:(NSString*)toastInfo parentView:(UIView *)parentView;
+ (NSString *)transImageURL2HttpsURL:(NSString *)httpURL;

+ (UIImage *)gsImage:(UIImage *)image withGsNumber:(CGFloat)blur;
+ (UIImage *)scaleImage:(UIImage *)image scaleToSize:(CGSize)size;
+ (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect;

+ (void)runInMainThread:(dispatch_block_t)block;
@end

NS_ASSUME_NONNULL_END
