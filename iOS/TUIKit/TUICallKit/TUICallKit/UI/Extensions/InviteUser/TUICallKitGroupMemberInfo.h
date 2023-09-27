//
//  TUICallKitGroupMemberInfo.h
//  Pods
//
//  Created by vincepzhang on 2023/4/11.
//Copyright © 2021 Tencent. All rights reserved

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICallKitGroupMemberInfo : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
