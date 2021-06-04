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
#import "TUIKit.h"

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPendencyChanged:) name:TUIGroupPendencyCellData_onPendencyChanged object:nil];

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupApplicationList:^(V2TIMGroupApplicationResult *result) {
        @strongify(self)
        NSMutableArray *list = @[].mutableCopy;
        for (V2TIMGroupApplication *item in result.applicationList) {
            if ([item.groupID isEqualToString:self.groupId] &&
                item.handleStatus == V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED) {
                TUIGroupPendencyCellData *data = [[TUIGroupPendencyCellData alloc] initWithPendency:item];
                [list addObject:data];
            }
        }
        self.dataList = list;
        self.unReadCnt = (int)list.count;
        self.isLoading = NO;
        self.hasNextData = NO;;
    } fail:nil];
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
