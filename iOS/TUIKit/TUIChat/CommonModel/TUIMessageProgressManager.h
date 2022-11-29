//
//  TUIMessageProgressManager.h
//  TUIChat
//
//  Created by harvy on 2022/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIMessageSendingResultType) {
    TUIMessageSendingResultTypeSucc   = 0,
    TUIMessageSendingResultTypeFail   = 1
};

@protocol TUIMessageProgressManagerDelegate <NSObject>

- (void)onProgress:(NSString *)msgID progress:(NSInteger)progress;

- (void)onMessageSendingResultChanged:(TUIMessageSendingResultType)type messageID:(NSString *)msgID;

@end

@interface TUIMessageProgressManager : NSObject

+ (instancetype)shareManager;

- (void)addDelegate:(id<TUIMessageProgressManagerDelegate>)delegate;
- (void)removeDelegate:(id<TUIMessageProgressManagerDelegate>)delegate;

- (void)appendProgress:(NSString *)msgID
              progress:(NSInteger)progress;
- (NSInteger)progressForMessage:(NSString *)msgID;

- (void)notifyMessageSendingResult:(NSString *)msgID
                            result:(TUIMessageSendingResultType)result;

@end

NS_ASSUME_NONNULL_END
