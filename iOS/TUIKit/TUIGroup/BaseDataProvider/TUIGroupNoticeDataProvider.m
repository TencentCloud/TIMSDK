//
//  TUIGroupNoticeDataProvider.m
//  TUIGroup
//
//  Created by harvy on 2022/1/12.
//

#import "TUIGroupNoticeDataProvider.h"

@interface TUIGroupNoticeDataProvider ()

@property (nonatomic, strong) V2TIMGroupInfo *groupInfo;

@end

@implementation TUIGroupNoticeDataProvider

- (void)getGroupInfo:(dispatch_block_t)callback
{
    if (self.groupInfo && [self.groupInfo.groupID isEqual:self.groupID]) {
        if (callback) {
            callback();
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance getGroupsInfo:@[self.groupID?:@""] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *result = groupResultList.firstObject;
        if (result && result.resultCode == 0) {
            weakSelf.groupInfo = result.info;
        }
        if (callback) {
            callback();
        }
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback();
        }
    }];
}

- (BOOL)canEditNotice
{
    return self.groupInfo.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN || self.groupInfo.role == V2TIM_GROUP_MEMBER_ROLE_SUPER;
}

- (void)updateNotice:(NSString *)notice callback:(void(^)(int, NSString *))callback
{
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupID;
    info.notification = notice;
    
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance setGroupInfo:info succ:^{
        if (callback) {
            callback(0, nil);
        }
        
        [weakSelf sendNoticeMessage:notice];
    } fail:^(int code, NSString *desc) {
        if (callback) {
            callback(code, desc);
        }
    }];
}

- (void)sendNoticeMessage:(NSString *)notice
{
    if (notice.length == 0) {
        return;
    }
}

@end
