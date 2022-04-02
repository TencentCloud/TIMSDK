//
//  TUIMessageProgressManager.h
//  TUIChat
//
//  Created by harvy on 2022/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMessageProgressManagerDelegate <NSObject>

- (void)onProgress:(NSString *)msgID progress:(NSInteger)progress;

@end

@interface TUIMessageProgressManager : NSObject

+ (instancetype)shareManager;

- (void)addDelegate:(id<TUIMessageProgressManagerDelegate>)delegate;
- (void)removeDelegate:(id<TUIMessageProgressManagerDelegate>)delegate;

- (void)appendProgress:(NSString *)msgID
              progress:(NSInteger)progress;
- (NSInteger)progressForMessage:(NSString *)msgID;

@end

NS_ASSUME_NONNULL_END
