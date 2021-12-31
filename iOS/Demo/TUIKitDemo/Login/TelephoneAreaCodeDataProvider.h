//
//  TelephoneAreaCodeDataProvider.h
//  TUIKitDemo
//
//  Created by harvy on 2021/12/14.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface TelephoneAreaCode : NSObject <NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *chineseName;
@property (nonatomic, copy) NSString *codeName;
@property (nonatomic, copy) NSString *code;

@property (nonatomic, copy, readonly) NSString *displayName;

@end

@interface TelephoneAreaCodeDataProvider : NSObject

// 索引
@property (nonatomic, strong, readonly) NSArray *indexs;
// 数据
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray<TelephoneAreaCode *> *> *datas;

- (void)searchWithKeyword:(NSString *)keyword callback:(dispatch_block_t)callback;

- (void)getPreferencesAreaCode:(void(^)(TelephoneAreaCode *))callback;

@end

NS_ASSUME_NONNULL_END
