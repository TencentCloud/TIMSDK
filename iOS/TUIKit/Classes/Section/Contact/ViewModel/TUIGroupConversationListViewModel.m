//
//  TUIGroupConversationListModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/11.
//

#import "TUIGroupConversationListViewModel.h"
#import "TUILocalStorage.h"
@import ImSDK;

@interface TUIGroupConversationListViewModel ()
@property BOOL isLoadFinished;
@property BOOL isLoading;
@property NSDictionary<NSString *, NSArray<TUIConversationCellData *> *> *dataDict;
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
    NSMutableDictionary *groupDict = @{}.mutableCopy;

    TIMManager *manager = [TIMManager sharedInstance];
    NSArray *convs = [manager getConversationList];
    for (TIMConversation *conv in convs) {
        
        TUIConversationCellData *data = [[TUIConversationCellData alloc] initWithConversation:conv];
        if ([data title].length == 0)
            continue;
        if ([data convType] != TIM_GROUP)
            continue;

        NSString *group = @"";
        if ([data.time timeIntervalSinceNow] < 3 * 24 * 60 * 60) {
            group = @"近三天";
            groupDict[@"1"] = group;
        }
        
        NSMutableArray *list = [dataDict objectForKey:group];
        if (!list) {
            list = @[].mutableCopy;
            dataDict[group] = list;
        }
        [list addObject:data];
    }
    for (NSString *key in groupDict) {
        [groupList addObject:groupDict[key]];
    }
    self.groupList = groupList;
    self.dataDict = dataDict;
    self.isLoadFinished = YES;
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
    [[TIMManager sharedInstance] deleteConversation:data.convType receiver:data.convId];
}


@end
