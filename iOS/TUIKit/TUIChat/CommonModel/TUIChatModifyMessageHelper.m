//
//  TUIChatModifyMessageHelper.m
//  TUIChat
//
//  Created by wyl on 2022/6/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatModifyMessageHelper.h"
#import <TUICore/TUILogin.h>
#import <TUICore/TUITool.h>
#import "TUICloudCustomDataTypeCenter.h"

#define RETRY_MIN_TIME 500
#define RETRY_MAX_TIME 3000

#define TIMES_CONTROL 3

@interface TUIChatModifyMessageObj : NSObject

@property(nonatomic, assign) NSInteger time;

@property(nonatomic, copy) NSString *msgID;

@property(nonatomic, strong) V2TIMMessage *msg;
// reply
@property(nonatomic, strong) NSDictionary *simpleCurrentContent;
// revoke
@property(nonatomic, copy) NSString *revokeMsgID;

@end

@implementation TUIChatModifyMessageObj
- (instancetype)init {
    if (self = [super init]) {
        self.time = 0;
    }
    return self;
}

- (V2TIMMessage *)resolveOriginCloudCustomData:(V2TIMMessage *)rootMsg {
    if (self.simpleCurrentContent) {
        return [self.class resolveOriginCloudCustomData:rootMsg simpleCurrentContent:self.simpleCurrentContent];
    }
    if (self.revokeMsgID) {
        return [self.class resolveOriginCloudCustomData:rootMsg revokeMsgID:self.revokeMsgID];
    }
    return rootMsg;
}

// Input
+ (V2TIMMessage *)resolveOriginCloudCustomData:(V2TIMMessage *)rootMsg simpleCurrentContent:(NSDictionary *)simpleCurrentContent {
    NSMutableDictionary *mudic = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSMutableArray *replies = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableDictionary *messageReplies = [[NSMutableDictionary alloc] initWithCapacity:5];

    if (rootMsg.cloudCustomData) {
        NSDictionary *originDic = [TUITool jsonData2Dictionary:rootMsg.cloudCustomData];
        if (originDic && [originDic isKindOfClass:[NSDictionary class]]) {
            [messageReplies addEntriesFromDictionary:originDic];
        }
        NSArray *messageRepliesArray = originDic[@"messageReplies"][@"replies"];
        if (messageRepliesArray && [messageRepliesArray isKindOfClass:NSArray.class] && messageRepliesArray.count > 0) {
            [replies addObjectsFromArray:messageRepliesArray];
        }
    }
    [replies addObject:simpleCurrentContent];
    [mudic setValue:replies forKey:@"replies"];

    [messageReplies setValue:mudic forKey:@"messageReplies"];
    [messageReplies setValue:@"1" forKey:@"version"];

    NSData *data = [TUITool dictionary2JsonData:messageReplies];
    if (data) {
        rootMsg.cloudCustomData = data;
    }

    return rootMsg;
}

// revoke

+ (V2TIMMessage *)resolveOriginCloudCustomData:(V2TIMMessage *)rootMsg revokeMsgID:(NSString *)revokeMsgId {
    NSMutableDictionary *mudic = [[NSMutableDictionary alloc] initWithCapacity:5];
    NSMutableArray *replies = [[NSMutableArray alloc] initWithCapacity:5];
    NSMutableDictionary *messageReplies = [[NSMutableDictionary alloc] initWithCapacity:5];

    if (rootMsg.cloudCustomData) {
        NSDictionary *originDic = [TUITool jsonData2Dictionary:rootMsg.cloudCustomData];
        if (originDic && [originDic isKindOfClass:[NSDictionary class]]) {
            [messageReplies addEntriesFromDictionary:originDic];
            if (originDic[@"messageReplies"] && [originDic[@"messageReplies"] isKindOfClass:[NSDictionary class]]) {
                NSArray *messageRepliesArray = originDic[@"messageReplies"][@"replies"];
                if (messageRepliesArray && [messageRepliesArray isKindOfClass:NSArray.class] && messageRepliesArray.count > 0) {
                    [replies addObjectsFromArray:messageRepliesArray];
                }
            }
        }
    }

    NSMutableArray *filterReplies = [[NSMutableArray alloc] initWithCapacity:5];
    [replies enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      if (obj && [obj isKindOfClass:NSDictionary.class]) {
          NSDictionary *dic = (NSDictionary *)obj;
          if (IS_NOT_EMPTY_NSSTRING(dic[@"messageID"])) {
              NSString *messageID = dic[@"messageID"];
              if (![messageID isEqualToString:revokeMsgId]) {
                  [filterReplies addObject:dic];
              }
          }
      }
    }];

    [mudic setValue:filterReplies forKey:@"replies"];

    [messageReplies setValue:mudic forKey:@"messageReplies"];
    [messageReplies setValue:@"1" forKey:@"version"];

    NSData *data = [TUITool dictionary2JsonData:messageReplies];
    if (data) {
        rootMsg.cloudCustomData = data;
    }

    return rootMsg;
}
@end

@interface ModifyCustomOperation : NSOperation

@property(nonatomic, strong) TUIChatModifyMessageObj *obj;

@property(nonatomic, copy) void (^SuccessBlock)(void);

@property(nonatomic, copy) void (^FailedBlock)(int code, NSString *desc, V2TIMMessage *msg);

@property(nonatomic, assign) BOOL bees_executing;

@property(nonatomic, assign) BOOL bees_finished;

@end

@implementation ModifyCustomOperation

- (void)dealloc {
    NSLog(@"operation-------dealloc");
}

- (void)start {
    if (self.isCancelled) {
        [self completeOperation];
        return;
    }

    __block V2TIMMessage *resolveMsg = nil;

    __weak typeof(self) weakSelf = self;

    self.bees_executing = YES;

    resolveMsg = [self.obj resolveOriginCloudCustomData:self.obj.msg];

    [[V2TIMManager sharedInstance] modifyMessage:resolveMsg
                                      completion:^(int code, NSString *desc, V2TIMMessage *msg) {
                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                        if (code != 0) {
                                            if (strongSelf.FailedBlock) {
                                                strongSelf.FailedBlock(code, desc, msg);
                                            }
                                        } else {
                                            if (strongSelf.SuccessBlock) {
                                                strongSelf.SuccessBlock();
                                            }
                                        }

                                        [strongSelf completeOperation];
                                      }];
}

- (void)completeOperation {
    self.bees_executing = NO;
    self.bees_finished = YES;
}

- (void)cancel {
    [super cancel];
    [self completeOperation];
}

#pragma mark - settter and getter
- (void)setBees_executing:(BOOL)bees_executing {
    [self willChangeValueForKey:@"isExecuting"];
    _bees_executing = bees_executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setBees_finished:(BOOL)bees_finished {
    [self willChangeValueForKey:@"isFinished"];
    _bees_finished = bees_finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isExecuting {
    return self.bees_executing;
}

- (BOOL)isFinished {
    return self.bees_finished;
}

@end

@interface TUIChatModifyMessageHelper () <V2TIMAdvancedMsgListener>

@property(nonatomic, strong) NSMutableDictionary<NSString *, TUIChatModifyMessageObj *> *modifyMessageHelperMap;

@property(nonatomic, strong) NSOperationQueue *queue;

@end

@implementation TUIChatModifyMessageHelper

+ (TUIChatModifyMessageHelper *)defaultHelper {
    static dispatch_once_t onceToken;
    static TUIChatModifyMessageHelper *config;
    dispatch_once(&onceToken, ^{
      config = [[TUIChatModifyMessageHelper alloc] init];
    });
    return config;
}

- (id)init {
    self = [super init];
    if (self) {
        [self registerTUIKitNotification];
        self.modifyMessageHelperMap = [NSMutableDictionary dictionaryWithCapacity:10];
        [self setupOpQueue];
    }
    return self;
}
- (void)setupOpQueue {
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
}

- (void)registerTUIKitNotification {
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
}

- (void)onRecvMessageModified:(V2TIMMessage *)msg {
    NSString *msgID = msg.msgID;
    TUIChatModifyMessageObj *obj = self.modifyMessageHelperMap[msgID];
    if (obj && [obj isKindOfClass:[TUIChatModifyMessageObj class]]) {
        // update;
        obj.msg = msg;
    }
}
#pragma mark - public

- (void)modifyMessage:(V2TIMMessage *)msg reactEmoji:(NSString *)emojiName {
    [self modifyMessage:msg reactEmoji:nil simpleCurrentContent:nil revokeMsgID:nil timeControl:0];
}

- (void)modifyMessage:(V2TIMMessage *)msg simpleCurrentContent:(NSDictionary *)simpleCurrentContent {
    [self modifyMessage:msg reactEmoji:nil simpleCurrentContent:simpleCurrentContent revokeMsgID:nil timeControl:0];
}

- (void)modifyMessage:(V2TIMMessage *)msg revokeMsgID:(NSString *)revokeMsgID {
    [self modifyMessage:msg reactEmoji:nil simpleCurrentContent:nil revokeMsgID:revokeMsgID timeControl:0];
}

#pragma mark - private
- (void)modifyMessage:(V2TIMMessage *)msg
              reactEmoji:(NSString *)emojiName
    simpleCurrentContent:(NSDictionary *)simpleCurrentContent
             revokeMsgID:(NSString *)revokeMsgID
             timeControl:(NSInteger)time {
    NSString *msgID = msg.msgID;
    if (!IS_NOT_EMPTY_NSSTRING(msgID)) {
        return;
    }

    TUIChatModifyMessageObj *obj = [[TUIChatModifyMessageObj alloc] init];
    obj.msgID = msgID;
    obj.msg = msg;
    obj.time = time;
    
    if (simpleCurrentContent) {
        obj.simpleCurrentContent = simpleCurrentContent;
    }
    if (revokeMsgID) {
        obj.revokeMsgID = revokeMsgID;
    }

    [self.modifyMessageHelperMap setObject:obj forKey:obj.msgID];

    __weak typeof(self) weakSelf = self;

    ModifyCustomOperation *modifyop = [[ModifyCustomOperation alloc] init];
    modifyop.obj = obj;
    modifyop.SuccessBlock = ^{
      __strong typeof(weakSelf) strongSelf = weakSelf;
      [strongSelf.modifyMessageHelperMap removeObjectForKey:msgID];
    };

    modifyop.FailedBlock = ^(int code, NSString *desc, V2TIMMessage *msg) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (obj.time <= TIMES_CONTROL) {
          int delay;
          delay = [self getRandomNumber:RETRY_MIN_TIME to:RETRY_MAX_TIME];

          TUIChatModifyMessageObj *obj = strongSelf.modifyMessageHelperMap[msgID];
          // update
          obj.msg = msg;
          obj.time = obj.time + 1;

          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            TUIChatModifyMessageObj *obj = strongSelf.modifyMessageHelperMap[msgID];
            if (obj && [obj isKindOfClass:[TUIChatModifyMessageObj class]]) {
                [strongSelf modifyMessage:obj.msg
                               reactEmoji:nil
                     simpleCurrentContent:obj.simpleCurrentContent
                              revokeMsgID:obj.revokeMsgID
                              timeControl:obj.time];
            }
          });
      } else {
          [strongSelf.modifyMessageHelperMap removeObjectForKey:msgID];
      }
    };

    if (!modifyop.isCancelled) {
        [self.queue addOperation:modifyop];
    }
}

- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

@end
