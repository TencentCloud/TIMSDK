//
//  NSObject+Extension.m
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "NSObject+CoreExtension.h"
@implementation NSObject (CoreExtension)

+ (NSString *)getRoomEngineKey {
    return @"TUIRoomKit.Room.Engine.Key";
}

+ (NSString *)getRoomInfoKey {
    return  @"TUIRoomKit.Room.Info.Key";
}

+ (NSString *)getLocalUserInfoKey {
    return @"TUIRoomKit.Local.User.Info.Key";
}

+ (NSString *)getTopViewKey {
    return @"TUIRoomKit.Top.Menu.View.Key";
}

+ (NSString *)getBottomViewKey  {
    return @"TUIRoomKit.Bottom.Menu.View.Key";
}

+ (NSString *)getUserListControllerKey  {
    return @"TUIRoomKit.User.List.Controller.Key";
}

+ (NSString *)getExtensionControllerKey  {
    return @"TUIRoomKit.Extension.Controller.Key";
}

@end
