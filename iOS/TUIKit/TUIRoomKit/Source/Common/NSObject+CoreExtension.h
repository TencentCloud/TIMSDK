//
//  NSObject+Extension.h
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/23.
//  Copyright (c) 2022年 Tencent. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CoreExtension)

+ (NSString *)getRoomEngineKey;

+ (NSString *)getRoomInfoKey;

+ (NSString *)getLocalUserInfoKey;

+ (NSString *)getTopViewKey;

+ (NSString *)getBottomViewKey;

+ (NSString *)getUserListControllerKey;

+ (NSString *)getExtensionControllerKey;
@end

NS_ASSUME_NONNULL_END
