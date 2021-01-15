//
//  TRTCV2TIMMessageObservable.m
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/17.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TRTCV2TIMMessageObservable.h"
#import <ImSDK/V2TIMManager.h>
//#import "V2TIMManager.h"

@interface TRTCV2TIMMessageObservable ()
@property(nonatomic, strong) NSMutableArray<id<V2TIMGroupListener>> *observers;
@end

@implementation TRTCV2TIMMessageObservable

- (instancetype)init {
    self = [super init];
    if (self) {
        self.observers = [NSMutableArray arrayWithCapacity:2];
        [self startListenGroupMessage];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startListenGroupMessage {
    NSArray *allNotifyNames = @[
        @"V2TIMGroupNotify_onMemberInvited",
        @"V2TIMGroupNotify_onMemberEnter",
        @"V2TIMGroupNotify_onMemberLeave",
        @"V2TIMGroupNotify_onGroupDismissed",
        @"V2TIMGroupNotify_onGroupRecycled",
        @"V2TIMGroupNotify_onGroupInfoChanged",
        @"V2TIMGroupNotify_onGroupAttributeChanged",
        @"V2TIMGroupNotify_onReceiveRESTCustomData",
        @"V2TIMGroupNotify_onRevokeAdministrator"
    ];
    for (NSString *notifyName in allNotifyNames) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotify:) name:notifyName object:nil];
    }
}

- (void)onNotify:(NSNotification *)notify {
    if (self.observers.count == 0) {
        return;
    }
    NSDictionary *userInfo = notify.userInfo?:@{};
    if ([notify.name isEqualToString:@"V2TIMGroupNotify_onMemberInvited"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onMemberInvited:opUser:memberList:)]) {
                [listener onMemberInvited:userInfo[@"groupID"] opUser:userInfo[@"opUser"] memberList:userInfo[@"memberList"]];
            }
        }];
    } else if ([notify.name isEqualToString:@"V2TIMGroupNotify_onMemberEnter"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onMemberEnter:memberList:)]) {
                [listener onMemberEnter:userInfo[@"groupID"] memberList:userInfo[@"memberList"]];
            }
        }];
    } else if ([notify.name isEqualToString:@"V2TIMGroupNotify_onMemberLeave"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onMemberLeave:member:)]) {
                [listener onMemberLeave:userInfo[@"groupID"] member:userInfo[@"member"]];
            }
        }];
    } else if ([notify.name isEqualToString:@"V2TIMGroupNotify_onGroupDismissed"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onGroupDismissed:opUser:)]) {
                [listener onGroupDismissed:userInfo[@"groupID"] opUser:userInfo[@"opUser"]];
            }
        }];
    } else if ([notify.name isEqualToString:@"V2TIMGroupNotify_onGroupRecycled"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onGroupRecycled:opUser:)]) {
                [listener onGroupRecycled:userInfo[@"groupID"] opUser:userInfo[@"opUser"]];
            }
        }];
    } else if ([notify.name isEqualToString:@"V2TIMGroupNotify_onGroupInfoChanged"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onGroupInfoChanged:changeInfoList:)]) {
                [listener onGroupInfoChanged:userInfo[@"groupID"] changeInfoList:userInfo[@"changeInfoList"]];
            }
        }];
    } else if ([notify.name isEqualToString:@"V2TIMGroupNotify_onGroupAttributeChanged"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onGroupAttributeChanged:attributes:)]) {
                [listener onGroupAttributeChanged:userInfo[@"groupID"] attributes:userInfo[@"attributes"]];
            }
        }];
    } else if ([notify.name isEqualToString:@"V2TIMGroupNotify_onReceiveRESTCustomData"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onReceiveRESTCustomData:data:)]) {
                [listener onReceiveRESTCustomData:userInfo[@"groupID"] data:userInfo[@"data"]];
            }
        }];
    } else if ([notify.name isEqualToString:@"V2TIMGroupNotify_onRevokeAdministrator"]) {
        [self fire:^(id<V2TIMGroupListener> listener) {
            if ([listener respondsToSelector:@selector(onRevokeAdministrator:opUser:memberList:)]) {
                [listener onRevokeAdministrator:userInfo[@"groupID"] opUser:userInfo[@"opUser"] memberList:userInfo[@"opUser"]];
            }
        }];
    }
}

- (void)fire:(void (^)(id<V2TIMGroupListener> listener))fireBlock {
    NSArray *observers = self.observers;
    for (NSValue *value in observers) {
        id<V2TIMGroupListener> listener = value.nonretainedObjectValue;
        if (listener) {
            fireBlock(listener);
        }
    }
}

- (void)addObserver:(id<V2TIMGroupListener>)listener {
    if (!listener) {
        return;
    }
    NSMutableArray *observers = [self.observers mutableCopy];
    for (NSValue *value in observers) {
        if ([value.nonretainedObjectValue isEqual:listener]) {
            return;/// 已存在
        }
    }
    /// 不存在，添加
    NSValue *value = [NSValue valueWithNonretainedObject:listener];
    [observers addObject:value];
    self.observers = observers;
}

- (void)removeObserver:(id<V2TIMGroupListener>)listener {
    NSMutableArray *observers = [self.observers mutableCopy];
    for (NSValue *value in observers) {
        if ([value.nonretainedObjectValue isEqual:listener]) {
            [observers removeObject:value];
            self.observers = observers;
            break;
        }
    }
}

@end
