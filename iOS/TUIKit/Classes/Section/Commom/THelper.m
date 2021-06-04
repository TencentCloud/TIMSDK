//
//  THelper.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/1.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "EMVoiceConverter.h"
#import "TUIKit.h"
#import "TUIError.h"
#import "SDWebImage/UIImage+GIF.h"

@implementation THelper


+ (NSString *)genImageName:(NSString *)uuid
{
    NSInteger sdkAppId = [TUIKit sharedInstance].sdkAppId;
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        int value = arc4random() % 1000;
        uuid = [NSString stringWithFormat:@"%ld_%d", (long)[[NSDate date] timeIntervalSince1970], value];
    }
    NSString *name = [NSString stringWithFormat:@"%ld_%@_image_%@", (long)sdkAppId, identifier, uuid];
    return name;
}

+ (NSString *)genSnapshotName:(NSString *)uuid
{
    NSInteger sdkAppId = [TUIKit sharedInstance].sdkAppId;
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%ld_%@_snapshot_%@", (long)sdkAppId, identifier, uuid];
    return name;
}

+ (NSString *)genVideoName:(NSString *)uuid
{
    NSInteger sdkAppId = [TUIKit sharedInstance].sdkAppId;
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%ld_%@_video_%@", (long)sdkAppId, identifier, uuid];
    return name;
}


+ (NSString *)genVoiceName:(NSString *)uuid withExtension:(NSString *)extent
{
    NSInteger sdkAppId = [TUIKit sharedInstance].sdkAppId;
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%ld_%@_voice_%@.%@", (long)sdkAppId, identifier, uuid, extent];
    return name;
}

+ (NSString *)genFileName:(NSString *)uuid
{
    NSInteger sdkAppId = [TUIKit sharedInstance].sdkAppId;
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%ld_%@_file_%@", (long)sdkAppId, identifier, uuid];
    return name;
}

+ (BOOL)isAmr:(NSString *)path
{
    return [EMVoiceConverter isAMRFile:path];
}

+ (BOOL)convertAmr:(NSString*)amrPath toWav:(NSString*)wavPath
{
    return [EMVoiceConverter amrToWav:amrPath wavSavePath:wavPath];
}

+ (BOOL)convertWav:(NSString*)wavPath toAmr:(NSString*)amrPath
{
    return [EMVoiceConverter wavToAmr:wavPath amrSavePath:amrPath];
}


+ (void)asyncDecodeImage:(NSString *)path complete:(TAsyncImageComplete)complete
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.tuikit.asyncDecodeImage", DISPATCH_QUEUE_SERIAL);
    });

    dispatch_async(queue, ^{
        if(path == nil){
            return;
        }

        UIImage *image = nil;
        
        if ([path containsString:@".gif"]) { //支持动图
            image = [UIImage sd_imageWithGIFData:[NSData dataWithContentsOfFile:path]];
            if(complete){
                complete(path, image);
            }
            return;
        } else {
            image = [UIImage tk_imagePath:path];
        }
        
        if (image == nil) {
            return;
        }

        // 获取CGImage
        CGImageRef cgImage = image.CGImage;

        // alphaInfo
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
        BOOL hasAlpha = NO;
        if (alphaInfo == kCGImageAlphaPremultipliedLast ||
            alphaInfo == kCGImageAlphaPremultipliedFirst ||
            alphaInfo == kCGImageAlphaLast ||
            alphaInfo == kCGImageAlphaFirst) {
            hasAlpha = YES;
        }

        // bitmapInfo
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
        bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;

        // size
        size_t width = CGImageGetWidth(cgImage);
        size_t height = CGImageGetHeight(cgImage);

        // 解码：把位图提前画到图形上下文，生成 cgImage，就完成了解码。
        // context
        CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);

        // draw
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);

        // get CGImage
        cgImage = CGBitmapContextCreateImage(context);

        // 解码后的图片，包装成 UIImage 。
        // into UIImage
        UIImage *newImage = [UIImage imageWithCGImage:cgImage scale:image.scale orientation:image.imageOrientation];

        // release
        if(context) CGContextRelease(context);
        if(cgImage) CGImageRelease(cgImage);

        //callback
        if(complete){
            complete(path, newImage);
        }
    });
}

+ (NSString *)randAvatarUrl
{
    return [NSString stringWithFormat:@"https://picsum.photos/id/%d/200/200", rand()%999];
}

+ (void)makeToast:(NSString *)str
{
    if ([TUIKit sharedInstance].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str];
    }
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration position:(CGPoint)position
{
    if ([TUIKit sharedInstance].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str duration:duration position:[NSValue valueWithCGPoint:position]];
    }
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration idposition:(id)position
{
    if ([TUIKit sharedInstance].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str duration:duration position:position];
    }
}

+ (void)makeToastError:(NSInteger)error msg:(NSString *)msg
{
    if ([TUIKit sharedInstance].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:[TUIError strError:error msg:msg]];
    }
}

+ (void)makeToastActivity
{
    if ([TUIKit sharedInstance].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToastActivity:CSToastPositionCenter];
    }
}

+ (void)hideToastActivity
{
    if ([TUIKit sharedInstance].enableToast) {
        [[UIApplication sharedApplication].keyWindow hideToastActivity];
    }
}

@end
