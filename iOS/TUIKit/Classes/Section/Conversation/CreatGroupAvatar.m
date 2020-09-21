//
//  CreatGroupAvatar.m
//  THeadImgs
//
//  Created by ITD on 2017/3/25.
//  Copyright © 2017年 ITD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreatGroupAvatar.h"
#import "THeader.h"
#import "TUIKit.h"
#import "SDWebImage/UIImageView+WebCache.h"

#define groupAvatarWidth (48*[[UIScreen mainScreen] scale])

@implementation CreatGroupAvatar

+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(NSData *groupAvatar))finished {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger avatarCount = group.count > 9 ? 9 : group.count;
        CGFloat width = groupAvatarWidth / 3 * 0.90;
        CGFloat space3 = (groupAvatarWidth - width * 3) / 4;                      // 三张图时的边距（图与图之间的边距）
        CGFloat space2 = (groupAvatarWidth - width * 2 + space3) / 2;             // 两张图时的边距
        CGFloat space1 = (groupAvatarWidth - width) / 2;                          // 一张图时的边距
        __block CGFloat y = avatarCount > 6 ? space3 : (avatarCount > 3 ? space2 : space1);
        __block CGFloat x = avatarCount  % 3 == 0 ? space3 : (avatarCount % 3 == 2 ? space2 : space1);
        width = avatarCount > 4 ? width : (avatarCount > 1 ? (groupAvatarWidth - 3 * space3) / 2 : groupAvatarWidth );  // 重新计算width；
        
        if (avatarCount == 1) {                                          // 1,2,3,4 张图不同
            x = 0;
            y = 0;
        }
        if (avatarCount == 2) {
            x = space3;
        } else if (avatarCount == 3) {
            x = (groupAvatarWidth -width)/2;
            y = space3;
        } else if (avatarCount == 4) {
            x = space3;
            y = space3;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, groupAvatarWidth, groupAvatarWidth)];
            [view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.6]];
            view.layer.cornerRadius = 6;
            __block NSInteger count = 0;               //下载图片完成的计数
            for (NSInteger i = avatarCount - 1; i >= 0; i--) {
                NSString *avatarUrl = [group objectAtIndex:i];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                [view addSubview:imageView];
                [imageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:DefaultAvatarImage completed:^(UIImage * _Nullable image,
                                                                                                                              NSError * _Nullable error,
                                                                                                                              SDImageCacheType cacheType,
                                                                                                                              NSURL * _Nullable imageURL) {
                    count ++ ;
                    if (count == avatarCount) {     //图片全部下载完成
                        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 2.0);
                        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndPDFContext();
                        CGImageRef imageRef = image.CGImage;
                        CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, CGRectMake(0, 0, view.frame.size.width*2, view.frame.size.height*2));
                        UIImage *ansImage = [[UIImage alloc] initWithCGImage:imageRefRect];
                        NSData *imageViewData = UIImagePNGRepresentation(ansImage);
                        CGImageRelease(imageRefRect);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (finished) {
                                finished(imageViewData);
                            }
                        });
                    }
                    
                }];
                
                if (avatarCount == 3) {
                    if (i == 2) {
                        y = width + space3*2;
                        x = space3;
                    } else {
                        x += width + space3;
                    }
                } else if (avatarCount == 4) {
                    if (i % 2 == 0) {
                        y += width +space3;
                        x = space3;
                    } else {
                        x += width +space3;
                    }
                } else {
                    if (i % 3 == 0 ) {
                        y += (width + space3);
                        x = space3;
                    } else {
                        x += (width + space3);
                    }
                }
            }
        });
        
    });
    
}



@end
