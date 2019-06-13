//
//  TUIImageCache.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIImageCache : NSObject

+ (instancetype)sharedInstance;

- (void)addResourceToCache:(NSString *)path;
- (UIImage *)getResourceFromCache:(NSString *)path;
- (void)addFaceToCache:(NSString *)path;
- (UIImage *)getFaceFromCache:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
