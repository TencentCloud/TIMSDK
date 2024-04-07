//
//  PAirSandbox.h
//  AirSandboxDemo
//
//  Created by gao feng on 2017/7/18.
//  Copyright © 2017 music4kid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAirSandbox : NSObject

+ (instancetype)sharedInstance;

- (void)enableSwipe;
- (void)showSandboxBrowser;

- (void)addAppGroup:(NSString *)groupId;

@end
