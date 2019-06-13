//
//  TContactSelectViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/8.
//

#import "TContactSelectViewModel.h"
#import "TCommonContactSelectCellData.h"
#import "NSString+Common.h"
#import "THeader.h"
#import "ReactiveObjC.h"
@import ImSDK;

@interface TContactSelectViewModel()
@property NSDictionary<NSString *, NSArray<TCommonContactSelectCellData *> *> *dataDict;
@property NSArray *groupList;
@property BOOL isLoadFinished;
@end

@implementation TContactSelectViewModel

- (void)loadContacts
{
    self.isLoadFinished = NO;
    
    NSArray<TIMFriend *> *friends = [[TIMFriendshipManager sharedInstance] queryFriendList];
    if (friends.count > 0) {
        [self fillList:friends];
    }
    else {
        @weakify(self)
        [[TIMFriendshipManager sharedInstance] getFriendList:^(NSArray<TIMFriend *> *friends) {
            @strongify(self)
            [self fillList:friends];
        } fail:nil];
    }
}

- (void)fillList:(NSArray<TIMFriend *> *)friends
{
    NSMutableDictionary *dataDict = @{}.mutableCopy;
    NSMutableArray *groupList = @[].mutableCopy;
    NSMutableArray *nonameList = @[].mutableCopy;
    
    for (TIMFriend *friend in friends) {
        TCommonContactSelectCellData *data = [TCommonContactSelectCellData new];
        [data updateFromFriend:friend];
        
        if (self.avaliableFilter && !self.avaliableFilter(data)) {
            continue;
        }
        if (self.disableFilter) {
            data.enabled = !self.disableFilter(data);
        }
        
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
    for (NSMutableArray *list in [self.dataDict allValues]) {
        [list sortUsingSelector:@selector(compare:)];
    }
    
    self.groupList = groupList;
    self.dataDict = dataDict;
    self.isLoadFinished = YES;
}

@end
