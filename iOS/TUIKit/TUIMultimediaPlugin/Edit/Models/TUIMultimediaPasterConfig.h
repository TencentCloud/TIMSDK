// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMultimediaPasterGroupConfig;
@class TUIMultimediaPasterItemConfig;

/**
 贴纸配置
 */
@interface TUIMultimediaPasterConfig : NSObject
@property(nonatomic) NSArray<TUIMultimediaPasterGroupConfig *> *groups;

+ (TUIMultimediaPasterConfig *)loadConfig;
+ (void)saveConfig:(TUIMultimediaPasterConfig *)config;
+ (NSURL *)saveCustomPaster:(UIImage *)img;
+ (void)removeCustomPaster:(TUIMultimediaPasterItemConfig *)paster;
@end

/**
 贴纸组，包含一系列贴纸
 */
@interface TUIMultimediaPasterGroupConfig : NSObject <NSSecureCoding>
@property(nonatomic) NSString *name;
@property(nullable, nonatomic) NSURL *iconUrl;
@property(nonatomic) BOOL customizable;  // 是否可由用户添加贴纸到此组
@property(nonatomic) NSArray<TUIMultimediaPasterItemConfig *> *itemList;

- (instancetype)initWithName:(NSString *)name
                     iconUrl:(nullable NSURL *)iconUrl
                    itemList:(NSArray<TUIMultimediaPasterItemConfig *> *)itemList
                customizable:(BOOL)customizable;
- (UIImage *)loadIcon;
@end

@interface TUIMultimediaPasterItemConfig : NSObject <NSSecureCoding>
@property(nullable, nonatomic) NSURL *imageUrl;
@property(nullable, nonatomic) NSURL *iconUrl;
@property(nonatomic) BOOL isUserAdded;
@property(nonatomic) BOOL isAddButton;

- (UIImage *)loadImage;
- (UIImage *)loadIcon;
@end

NS_ASSUME_NONNULL_END
