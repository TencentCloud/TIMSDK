//
//  TUIGroupMemberDataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/7/2.
//

#import "TUIGroupMemberDataProvider.h"
#import "TUIMemberInfoCellData.h"
#import "TUIDefine.h"

@interface TUIGroupMemberDataProvider()
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, assign) NSUInteger index;
@end

@implementation TUIGroupMemberDataProvider
- (instancetype)initWithGroupID:(NSString *)groupID {
    self = [super init];
    if (self) {
        self.groupID = groupID;
    }
    return self;
}

- (void)loadDatas:(void(^)(BOOL success, NSString *err, NSArray *datas))completion
{
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:self.index succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        self.index = nextSeq;
        self.isNoMoreData = (nextSeq == 0);
        NSMutableArray *arrayM = [NSMutableArray array];
        NSMutableArray *ids = [NSMutableArray array];
        NSMutableDictionary *map = [NSMutableDictionary dictionary];
        for (V2TIMGroupMemberFullInfo *member in memberList) {
            TUIMemberInfoCellData *user = [[TUIMemberInfoCellData alloc] init];
            user.identifier = member.userID;
            if (member.nameCard.length > 0) {
                user.name = member.nameCard;
            } else if (member.friendRemark.length > 0) {
                user.name = member.friendRemark;
            } else if (member.nickName.length > 0) {
                user.name = member.nickName;
            } else {
                user.name = member.userID;
            }
            [arrayM addObject:user];
            [ids addObject:user.identifier];
            if (user.identifier && user) {
                map[user.identifier] = user;
            }
        }
        // 批量获取头像 faceURL
        [[V2TIMManager sharedInstance] getUsersInfo:ids succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            NSArray *userIDs =  map.allKeys;
            for (V2TIMUserFullInfo *info in infoList) {
                if (![userIDs containsObject:info.userID]) {
                    continue;
                }
                TUIMemberInfoCellData *user = map[info.userID];
                user.avatarUrl = info.faceURL;
            }
            if (completion) {
                completion(YES, @"", arrayM);
            }
        } fail:^(int code, NSString *desc) {
            if (completion) {
                completion(NO, desc, @[]);
            }
        }];
        
    } fail:^(int code, NSString *msg) {
        if (completion) {
            completion(NO, msg, @[]);
        }
    }];
}

@end
