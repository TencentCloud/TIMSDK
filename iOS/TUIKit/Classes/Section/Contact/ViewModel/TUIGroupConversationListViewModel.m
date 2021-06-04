//
//  TUIGroupConversationListModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/11.
//

#import "TUIGroupConversationListViewModel.h"
#import "THeader.h"
#import "TUILocalStorage.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "NSString+TUICommon.h"

@interface TUIGroupConversationListViewModel ()
@property BOOL isLoadFinished;
@property BOOL isLoading;
@property NSDictionary<NSString *, NSArray<TCommonContactCellData *> *> *dataDict;
@property NSArray *groupList;
@end

@implementation TUIGroupConversationListViewModel

- (void)loadConversation
{
    if (self.isLoading)
        return;
    self.isLoading = NO;
    self.isLoadFinished = NO;


    NSMutableDictionary *dataDict = @{}.mutableCopy;
    NSMutableArray *groupList = @[].mutableCopy;
    NSMutableArray *nonameList = @[].mutableCopy;

    @weakify(self)
    [[V2TIMManager sharedInstance] getJoinedGroupList:^(NSArray<V2TIMGroupInfo *> *infoList) {
        @strongify(self)
        for (V2TIMGroupInfo *group in infoList) {

            TCommonContactCellData *data = [[TCommonContactCellData alloc] initWithGroupInfo:group];

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
    } fail:nil];
}

- (void)removeData:(TUIConversationCellData *)data
{
    NSMutableDictionary *dictDict = [NSMutableDictionary dictionaryWithDictionary:self.dataDict];
    for (NSString *key in self.dataDict) {
        NSMutableArray *list = [NSMutableArray arrayWithArray:self.dataDict[key]];
        if ([list containsObject:data]) {
            [list removeObject:data];
            dictDict[key] = list;
            break;
        }
    }
    self.dataDict = dictDict;
}


@end
