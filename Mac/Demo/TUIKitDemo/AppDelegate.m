//
//  AppDelegate.m
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/22.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import "AppDelegate.h"
#import "ImSDK.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[TIMManager sharedInstance] unInit];
}


@end
