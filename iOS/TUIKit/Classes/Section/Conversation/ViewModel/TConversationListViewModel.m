//
//  TConversationListViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TConversationListViewModel.h"
#import "TUILocalStorage.h"
@import ImSDK;

@interface TConversationListViewModel ()
@property BOOL isLoadFinished;
@property BOOL isLoading;
@end

@implementation TConversationListViewModel

- (void)loadConversation
{
    if (self.isLoading)
        return;
    self.isLoading = NO;
    self.isLoadFinished = NO;

    NSArray *topList = [[TUILocalStorage sharedInstance] topConversationList];
    int existTopListSize = 0;
    
    NSMutableArray *dataList = @[].mutableCopy;
    TIMManager *manager = [TIMManager sharedInstance];
    NSArray *convs = [manager getConversationList];
    for (TIMConversation *conv in convs) {
        
        TUIConversationCellData *data = [[TUIConversationCellData alloc] initWithConversation:conv];
        if ([data title].length == 0)
            continue;
        if (self.listFilter) {
            if (!self.listFilter(data))
                continue;
        }
        if ([topList containsObject:data.convId]) {
            [dataList insertObject:data atIndex:existTopListSize++];
        } else {
            [dataList addObject:data];
        }
    }
    self.dataList = dataList;
}

- (void)removeData:(TUIConversationCellData *)data
{
    NSMutableArray *list = [NSMutableArray arrayWithArray:self.dataList];
    [list removeObject:data];
    self.dataList = list;
    [[TIMManager sharedInstance] deleteConversation:data.convType receiver:data.convId];
}

@end
