//
//  TUIGroupPendencyViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//

#import "TUIGroupPendencyViewModel.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TUIGroupPendencyCellData.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
@import ImSDK;

@interface TUIGroupPendencyViewModel()

@property NSArray *dataList;

@property (nonatomic,assign) uint64_t origSeq;

@property (nonatomic,assign) uint64_t seq;

@property (nonatomic,assign) uint64_t timestamp;

@property (nonatomic,assign) uint64_t numPerPage;

@end

@implementation TUIGroupPendencyViewModel

- (instancetype)init
{
    self = [super init];
    
    _numPerPage = 100;
    _dataList = @[];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewMessage:) name:TUIKitNotification_TIMMessageListener object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPendencyChanged:) name:TUIGroupPendencyCellData_onPendencyChanged object:nil];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onNewMessage:(NSNotification *)notification
{
    NSArray *msgs = notification.object;
    for (TIMMessage *msg in msgs) {
        for (int i = 0; i < msg.elemCount; ++i) {
            TIMElem *elem = [msg getElem:i];
            if ([elem isKindOfClass:[TIMGroupSystemElem class]]) {
                TIMGroupSystemElem *gt = (TIMGroupSystemElem *)elem;
                if ([[gt group] isEqualToString:_groupId] && gt.type == TIM_GROUP_SYSTEM_ADD_GROUP_REQUEST_TYPE) {
                    [self loadData];
                    break;
                }
            }
        }
    }
}

- (void)onPendencyChanged:(NSNotification *)notification
{
    int unReadCnt = 0;
    for (TUIGroupPendencyCellData *data in self.dataList) {
        if (data.isRejectd || data.isAccepted) {
            continue;
        }
        unReadCnt++;
    }
    self.unReadCnt = unReadCnt;
}

- (void)loadData
{
    if (self.isLoading)
        return;
    
    self.isLoading = YES;
    TIMGroupPendencyOption *option = [[TIMGroupPendencyOption alloc] init];
    option.numPerPage = 100;
    
    @weakify(self)
    [[TIMGroupManager sharedInstance] getPendencyFromServer:option succ:^(TIMGroupPendencyMeta *meta, NSArray *pendencies) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (TIMGroupPendencyItem *item in pendencies) {
            if ([item.groupId isEqualToString:self.groupId] &&
                item.handleStatus == TIM_GROUP_PENDENCY_HANDLE_STATUS_UNHANDLED) {
                TUIGroupPendencyCellData *data = [[TUIGroupPendencyCellData alloc] initWithPendency:item];
                [list addObject:data];
            }
        }
        self.timestamp = meta.nextStartTime;
        self.dataList = list;
        self.unReadCnt = (int)list.count;
        self.isLoading = NO;
        if ([list count] > 0) {
            self.hasNextData = YES;
        }
    } fail:nil];
}

- (void)loadNextData
{
    // TODO
}

- (void)acceptData:(TUIGroupPendencyCellData *)data
{
    [data accept];
    self.unReadCnt--;
}

- (void)removeData:(TUIGroupPendencyCellData *)data
{
    NSMutableArray *dataList = [NSMutableArray arrayWithArray:self.dataList];
    [dataList removeObject:data];
    self.dataList = dataList;
    [data reject];
    self.unReadCnt--;
}

@end
