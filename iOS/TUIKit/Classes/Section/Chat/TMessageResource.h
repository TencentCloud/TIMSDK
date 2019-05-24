//
//  TMessageResource.h
//  TUIKit
//
//  Created by kennethmiao on 2018/11/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TMessageResource : NSObject
- (UIImage *)imageForKey:(NSString *)path;
- (void)setImageForKey:(NSString *)path;
@end
