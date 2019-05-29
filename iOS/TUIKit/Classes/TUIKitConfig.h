//
//  TUIKitConfig.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/5.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TUIKitConfig : NSObject
@property (nonatomic, strong) NSMutableArray *faceGroups;
@property (nonatomic, strong) NSMutableArray *moreMenus;
@property (nonatomic, assign) NSInteger msgCountPerRequest;

+ (id)defaultConfig;


//提前加载资源（全路径）
- (void)addResourceToCache:(NSString *)path;
- (UIImage *)getResourceFromCache:(NSString *)path;
- (void)addFaceToCache:(NSString *)path;
- (UIImage *)getFaceFromCache:(NSString *)path;
@end
