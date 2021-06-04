//
//  TContactViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TContactViewModel.h"
#import "NSString+TUICommon.h"
#import "TUIKit.h"
#import "TUILocalStorage.h"

@interface TContactViewModel()
@property NSDictionary<NSString *, NSArray<TCommonContactCellData *> *> *dataDict;
@property NSArray *groupList;
@property BOOL isLoadFinished;
@property NSUInteger pendencyCnt;
@end

@implementation TContactViewModel

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
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getFriendList:^(NSArray<V2TIMFriendInfo *> *infoList) {
        NSMutableDictionary *dataDict = @{}.mutableCopy;
        NSMutableArray *groupList = @[].mutableCopy;
        NSMutableArray *nonameList = @[].mutableCopy;

        for (V2TIMFriendInfo *friend in infoList) {
            TCommonContactCellData *data = [[TCommonContactCellData alloc] initWithFriend:friend];
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
        weakSelf.groupList = groupList;
        weakSelf.dataDict = dataDict;
        weakSelf.isLoadFinished = YES;
    } fail:nil];

    // 好友请求
    [self loadFriendApplication];
}

- (void)loadFriendApplication
{
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getFriendApplicationList:^(V2TIMFriendApplicationResult *result) {
        weakSelf.pendencyCnt = result.unreadCount;
    } fail:nil];
}

- (void)clearApplicationCnt
{
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] setFriendApplicationRead:^{
        weakSelf.pendencyCnt = 0;
    } fail:nil];
}
@end
