//
//  THelper.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/1.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+Toast.h"

typedef void (^TAsyncImageComplete)(NSString *path, UIImage *image);

@interface THelper : NSObject
+ (NSString *)genImageName:(NSString *)uuid;
+ (NSString *)genSnapshotName:(NSString *)uuid;
+ (NSString *)genVideoName:(NSString *)uuid;
+ (NSString *)genFileName:(NSString *)uuid;
+ (NSString *)genVoiceName:(NSString *)uuid withExtension:(NSString *)extent;
+ (BOOL)isAmr:(NSString *)path;
+ (BOOL)convertAmr:(NSString*)amrPath toWav:(NSString*)wavPath;
+ (BOOL)convertWav:(NSString*)wavPath toAmr:(NSString*)amrPath;
+ (void)asyncDecodeImage:(NSString *)path complete:(TAsyncImageComplete)complete;
+ (NSString *)randAvatarUrl;
+ (void)makeToast:(NSString *)str;
+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration position:(CGPoint)position;
+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration idposition:(id)position;
+ (void)makeToastError:(NSInteger)error msg:(NSString *)msg;
+ (void)makeToastActivity;
+ (void)hideToastActivity;
@end
