//
//  AlbumPicker.h
//  TUIChat
//
//  Created by yiliangwang on 2024/10/30.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAlbumPicker <NSObject>
- (void)pickMediaWithCaller:(UIViewController *)caller;
@end


NS_ASSUME_NONNULL_BEGIN

@interface AlbumPicker : NSObject

@property(nonatomic,strong) id<IAlbumPicker> advancedAlbumPicker;

+ (instancetype)sharedInstance;
+ (void)registerAdvancedAlbumPicker:(id<IAlbumPicker>)albumPicker;
+ (void)pickMediaWithCaller:(UIViewController *)caller;
@end

NS_ASSUME_NONNULL_END
