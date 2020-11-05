//
//  TUILiveStatisticsTool.m
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by abyyxwang on 2020/9/21.
//

#import "TUILiveStatisticsTool.h"

@implementation TUILiveStatisticsTool
{
    NSTimer              *_timer;
    NSInteger            _startTime;
    NSInteger            _liveDuration;      // 直播时长
    NSInteger            _audienceCount;     // 在线观众数
    NSInteger            _likeCount;         // 点赞数
    NSInteger            _totalViewerCount;  // 总共观看人数
    
    BOOL                 _isHost;            // 是否是主播
    NSString             *_hostNickName;     // 主播昵称
    NSString             *_hostFaceUrl;      // 头像地址
}

- (instancetype)initWithIsHost:(BOOL)isHost audienceCount:(NSInteger)audienceCount likeCount:(NSInteger)likeCount {
    if (self = [super init]) {
        _audienceCount = audienceCount;
        _totalViewerCount = audienceCount;
        _likeCount = likeCount;
        _liveDuration = 0;

        _isHost = isHost;
    }
    return self;
}

- (void)setViewerCount:(int)viewerCount likeCount:(int)likeCount {
    _audienceCount = viewerCount;
    _totalViewerCount = viewerCount;
    _likeCount = likeCount;
}

- (void)startLive {
    if (_isHost) {
        _startTime = (NSInteger)[[NSDate date] timeIntervalSince1970];
        
        if (_timer) {
            [_timer invalidate];
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onLiveTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)pauseLive {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)resumeLive {
    [self startLive];
}

- (NSInteger)getViewerCount {
    return _audienceCount;
}

- (NSInteger)getLikeCount {
    return _likeCount;
}

- (NSInteger)getTotalViewerCount {
    return _totalViewerCount;
}

- (NSInteger)getLiveDuration {
    return _liveDuration;
}

- (void)onLiveTimer {
    NSInteger curTime = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger dur = curTime - _startTime;
    
    NSString *durStr = nil;
    int h = (int)dur/3600;
    int m = (int)(dur - h *3600)/60;
    int s = (int)dur%60;
    durStr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
    _liveDuration = dur;
}

- (void)onUserEnterLiveRoom {
    _audienceCount ++;
    _totalViewerCount ++;
}

- (void)onUserExitLiveRoom {
    if (_audienceCount > 0) {
        _audienceCount --;
    }
}

- (void)onUserSendLikeMessage {
    _likeCount ++;
}



@end
