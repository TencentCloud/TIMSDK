//
//  TUIImageCache.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/15.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/** 腾讯云 TUIImageCache
 *
 *
 *  本类依赖于腾讯云 IM SDK 实现
 *  TUIKit 中的组件在实现 UI 功能的同时，调用 IM SDK 相应的接口实现 IM 相关逻辑和数据的处理
 *  您可以在TUIKit的基础上做一些个性化拓展，即可轻松接入IM SDK
 *
 *  TUIImageCache 提供了将图像信息保存在本地缓存中的功能，使您能够快速的从本地缓存中获取已有图像
 */
@interface TUIImageCache : NSObject

+ (instancetype)sharedInstance;

/**
 *  将图像资源添加进本地缓存中
 *
 *  @param path 本地缓存所在路径
 */
- (void)addResourceToCache:(NSString *)path;

/**
 *  从本地缓存获取图像资源
 *
 *  @param path 本地缓存所在路径
 */
- (UIImage *)getResourceFromCache:(NSString *)path;

/**
 *  将表情添加进本地缓存中
 *
 *  @param path 本地缓存所在路径
 */
- (void)addFaceToCache:(NSString *)path;

/**
 *  从本地缓存获取表情资源
 *
 *  @param path 本地缓存所在路径
 */
- (UIImage *)getFaceFromCache:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
