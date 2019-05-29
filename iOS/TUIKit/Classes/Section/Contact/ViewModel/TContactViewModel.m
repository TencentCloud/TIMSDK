//
//  TContactViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/5.
//

#import "TContactViewModel.h"
#import "NSString+Common.h"
#import "THeader.h"
@import ImSDK;

@interface TContactViewModel()
@property NSDictionary<NSString *, NSArray<TCommonContactCellData *> *> *dataDict;
@property NSArray *groupList;
@property BOOL isLoadFinished;
@end

@implementation TContactViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)loadContacts
{
    self.isLoadFinished = NO;
    
    [[TIMFriendshipManager sharedInstance] getFriendList:^(NSArray<TIMFriend *> *friends) {
        NSMutableDictionary *dataDict = @{}.mutableCopy;
        NSMutableArray *groupList = @[].mutableCopy;
        NSMutableArray *nonameList = @[].mutableCopy;
        
        for (TIMFriend *friend in friends) {
            TCommonContactCellData *data = [[TCommonContactCellData alloc] initWithFriend:friend];
            data.cselector = self.contactSelector;
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
        if (self.firstGroupData) {
            dataDict[@" "] = self.firstGroupData;
            [groupList insertObject:@" " atIndex:0];
        }
        
        self.groupList = groupList;
        self.dataDict = dataDict;
        self.isLoadFinished = YES;
    } fail:nil];
}
@end
