//
//  TUILiveStatisticsTool.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveStatisticsTool : NSObject

- (instancetype)initWithIsHost:(BOOL)isHost audienceCount:(NSInteger)audienceCount likeCount:(NSInteger)likeCount;

- (void)setViewerCount:(int)viewerCount likeCount:(int)likeCount;

- (void)startLive;
- (void)pauseLive;
- (void)resumeLive;

- (NSInteger)getViewerCount;       // 获取在线观看人数
- (NSInteger)getLikeCount;
- (NSInteger)getTotalViewerCount;  // 获取累计观看人数
- (NSInteger)getLiveDuration;

- (void)onUserEnterLiveRoom;
- (void)onUserExitLiveRoom;
- (void)onUserSendLikeMessage;

@end

NS_ASSUME_NONNULL_END
