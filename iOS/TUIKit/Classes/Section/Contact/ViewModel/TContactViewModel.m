#import "TContactViewModel.h"
#import "NSString+Common.h"
#import "THeader.h"
#import "TUILocalStorage.h"
@import ImSDK;

@interface TContactViewModel()
@property NSDictionary<NSString *, NSArray<TCommonContactCellData *> *> *dataDict;
@property NSArray *groupList;
@property BOOL isLoadFinished;
@property NSUInteger pendencyCnt;
@property NSUInteger pendencyReadTimestamp;
@property NSUInteger pendencyLastTimestamp;
@end

@implementation TContactViewModel

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPendency) name:TUIKitNotification_onAddFriendReqs object:nil];
        self.pendencyReadTimestamp = [TUILocalStorage sharedInstance].pendencyReadTimestamp;
        self.pendencyLastTimestamp = self.pendencyReadTimestamp;
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
    
    [[TIMFriendshipManager sharedInstance] getFriendList:^(NSArray<TIMFriend *> *friends) {
        NSMutableDictionary *dataDict = @{}.mutableCopy;
        NSMutableArray *groupList = @[].mutableCopy;
        NSMutableArray *nonameList = @[].mutableCopy;
        
        for (TIMFriend *friend in friends) {
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
        
        self.groupList = groupList;
        self.dataDict = dataDict;
        self.isLoadFinished = YES;
    } fail:nil];
    
    // 好友请求
    [self loadPendency];
}

- (void)loadPendency
{
    TIMFriendPendencyRequest *req = TIMFriendPendencyRequest.new;
    req.numPerPage = 100;
    req.type = TIM_PENDENCY_COME_IN;
    
    [[TIMFriendshipManager sharedInstance] getPendencyList:req succ:^(TIMFriendPendencyResponse *pendencyResponse) {
        int n = 0;
        for (TIMFriendPendencyItem *item in pendencyResponse.pendencies) {
            if (item.addTime > self.pendencyReadTimestamp) {
                n++;
            }
            self.pendencyLastTimestamp = MAX(self.pendencyLastTimestamp, item.addTime);
        }
        self.pendencyCnt = n;
    } fail:nil];
}

- (void)clearPendencyCnt
{
    self.pendencyReadTimestamp = self.pendencyLastTimestamp;
    [[TUILocalStorage sharedInstance] setPendencyReadTimestamp:self.pendencyLastTimestamp];
    self.pendencyCnt = 0;
}
@end
