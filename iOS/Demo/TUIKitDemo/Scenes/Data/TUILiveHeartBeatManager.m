//
//  TUILiveHeartBeatManager.m
//  Pods
//
//  Created by harvy on 2020/9/25.
//

#import "TUILiveHeartBeatManager.h"
#import "TUIKitLive.h"
#import "TUILiveRoomManager.h"

@interface TUILiveHeartBeatManager ()

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, weak) NSTimer  *timer;

@end

@implementation TUILiveHeartBeatManager

static id _instance;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)startWithType:(NSString *)type roomId:(NSString *)roomId
{
    NSLog(@"[CreateRoom][heart] %s, type:%@ rooId:%@", __func__, type, roomId);
    if (roomId == nil || roomId.length == 0) {
        return;
    }
    
    self.type   = type;
    self.roomId = roomId;
    
    [self startTimer];
    
    // 立马发心跳
    [self actionTimer:nil];
}

- (void)stop
{
    NSLog(@"[CreateRoom][heart] %s,", __func__);
    [self endTimer];
    self.roomId = nil;
}


#pragma mark - 创建房间后的轮训心跳
- (void)startTimer
{
    [self endTimer];
    NSTimer *timer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(actionTimer:) userInfo:nil repeats:YES];
    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)endTimer
{
    if (self.timer) {
        [self.timer invalidate];
    }
    self.timer = nil;
}

- (void)actionTimer:(NSTimer *)timer
{
    [TUILiveRoomManager.sharedManager updateRoom:TUIKitLive.shareInstance.sdkAppId type:self.type roomID:self.roomId success:nil failed:nil];
}

@end
