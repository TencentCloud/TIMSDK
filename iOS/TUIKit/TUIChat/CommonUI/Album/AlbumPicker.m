//
//  AlbumPicker.m
//  TUIChat
//
//  Created by yiliangwang on 2024/10/30.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "AlbumPicker.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlbumPicker()

@end

@implementation AlbumPicker

+ (instancetype)sharedInstance {
    static AlbumPicker *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)registerAdvancedAlbumPicker:(id<IAlbumPicker>)albumPicker {
    [AlbumPicker sharedInstance].advancedAlbumPicker = albumPicker;
}

+ (void)pickMediaWithCaller:(UIViewController *)caller  {
    id<IAlbumPicker> albumPicker = nil;
    if ([AlbumPicker sharedInstance].advancedAlbumPicker) {
        albumPicker = [AlbumPicker sharedInstance].advancedAlbumPicker;
    }
    
    if (albumPicker && [albumPicker respondsToSelector:@selector
                        (pickMediaWithCaller:)]) {
        [albumPicker pickMediaWithCaller:caller];
    }
}

@end
