// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK_Professional/TXLiveRecordTypeDef.h>
#import <TXLiteAVSDK_Professional/TXVideoEditerTypeDef.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define TUIMultimediaConstCGSize(w, h) ((CGSize){(CGFloat)(w), (CGFloat)(h)})

static const int TUIMultimediaEditBitrate = 12000;

@interface TUIMultimediaCommon : NSObject
@property(class, readonly) NSBundle *bundle;
@property(class, readonly) NSBundle *localizableBundle;
+ (nullable UIImage *)bundleImageByName:(NSString *)name;
+ (nullable UIImage *)bundleRawImageByName:(NSString *)name;
+ (NSString *)localizedStringForKey:(NSString *)key;
+ (UIColor *)colorFromHex:(NSString *)hex;
+ (NSArray<NSString *> *)sortedBundleResourcesIn:(NSString *)directory withExtension:(NSString *)ext;

+ (NSURL *)getURLByResourcePath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
