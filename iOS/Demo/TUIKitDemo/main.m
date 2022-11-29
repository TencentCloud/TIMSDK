//
//  main.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSString * delegateClass = @"AppDelegate";
        Class combineCls = NSClassFromString(@"TUICombineDelegate");
        NSString *combineClsStr = NSStringFromClass(combineCls);
        if (combineClsStr.length>0) {
            delegateClass = @"TUICombineDelegate";
        }        
        return UIApplicationMain(argc, argv, nil, delegateClass);
    }
}
