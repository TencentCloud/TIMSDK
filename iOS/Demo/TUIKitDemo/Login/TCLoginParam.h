//
//  TCLoginParam.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/4.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 腾讯云IM Demo用户登录信息类
 *  用来管理用户的登录信息，如登录信息的缓存、过期判断等
 */
@interface TCLoginParam : NSObject

@property (nonatomic, assign) NSInteger tokenTime;
@property (nonatomic, assign) BOOL      isLastAppExt;
@property (nonatomic, copy) NSString*   identifier;
@property (nonatomic, copy) NSString*   hashedPwd;

+ (instancetype)shareInstance;

+ (instancetype)loadFromLocal;

- (void)saveToLocal;

- (BOOL)isExpired;

- (BOOL)isValid;

@end
