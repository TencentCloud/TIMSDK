//
//  TContactViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TUIContactViewDataProvider.h"
#import "TUIDefine.h"
#import "NSString+TUIUtil.h"

@interface TUIContactViewDataProvider()
@property NSDictionary<NSString *, NSArray<TUICommonContactCellData *> *> *dataDict;
@property NSArray *groupList;
@property BOOL isLoadFinished;
@property NSUInteger pendencyCnt;
@end

@implementation TUIContactViewDataProvider

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadContacts
{
    self.isLoadFinished = NO;
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        @strongify(self)
        NSMutableDictionary *dataDict = @{}.mutableCopy;
        NSMutableArray *groupList = @[].mutableCopy;
        NSMutableArray *nonameList = @[].mutableCopy;

        for (V2TIMFriendInfo *friend in infoList) {
            TUICommonContactCellData *data = [[TUICommonContactCellData alloc] initWithFriend:friend];
            NSString *group = [[data.title firstPinYin] uppercaseString];
            if (group.length == 0 || !isalpha([group characterAtIndex:0])) {
                [nonameList addObject:data];
                continue;
            }
            NSMutableArray *list = [dataDict objectForKey:group];
            if (!list) {
                list = @[].mutableCopy;
                dataDict[group] = list;
                [groupList addObject:group];
            }
            [list addObject:data];
        }

        [groupList sortUsingSelector:@selector(localizedStandardCompare:)];
        if (nonameList.count) {
            [groupList addObject:@"#"];
            dataDict[@"#"] = nonameList;
        }
        for (NSMutableArray *list in [dataDict allValues]) {
            [list sortUsingSelector:@selector(compare:)];
        }
        self.groupList = groupList;
        self.dataDict = dataDict;
        self.isLoadFinished = YES;
    } fail:^(int code, NSString *desc) {
        NSLog(@"getFriendList failed, code:%d desc:%@", code, desc);
    }];

    // 好友请求
    [self loadFriendApplication];
}

- (void)loadFriendApplication
{
    @weakify(self)
    [[V2TIMManager sharedInstance] getFriendApplicationList:^(V2TIMFriendApplicationResult *result) {
        @strongify(self)
        self.pendencyCnt = result.unreadCount;
    } fail:nil];
}

- (void)clearApplicationCnt
{
    @weakify(self)
    [[V2TIMManager sharedInstance] setFriendApplicationRead:^{
        @strongify(self)
        (self).pendencyCnt = 0;
    } fail:nil];
}
@end
