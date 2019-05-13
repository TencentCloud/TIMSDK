//
//  TNewFriendViewModel.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TNewFriendViewModel.h"
@import ImSDK;

@interface TNewFriendViewModel()

@property NSArray *dataList;

@property (nonatomic,assign) uint64_t origSeq;

@property (nonatomic,assign) uint64_t seq;

@property (nonatomic,assign) uint64_t timestamp;

@property (nonatomic,assign) uint64_t numPerPage;

@end

@implementation TNewFriendViewModel

- (instancetype)init
{
    self = [super init];
    
    _numPerPage = 5;
    _dataList = @[];
    
    return self;
}

- (void)loadData
{
    if (self.isLoading)
        return;
    
    self.isLoading = YES;
    TIMFriendPendencyRequest *req = TIMFriendPendencyRequest.new;
    req.numPerPage = self.numPerPage;
    req.type = TIM_PENDENCY_COME_IN;
    
    [[TIMFriendshipManager sharedInstance] getPendencyList:req succ:^(TIMFriendPendencyResponse *pendencyResponse) {
        NSMutableArray *list = @[].mutableCopy;
        for (TIMFriendPendencyItem *item in pendencyResponse.pendencies) {
            TCommonPendencyCellData *data = [[TCommonPendencyCellData alloc] initWithPendency:item];
            [list addObject:data];
        }
        self.seq = pendencyResponse.seq;
        self.timestamp = pendencyResponse.timestamp;
        self.dataList = list;
        self.isLoading = NO;
        if ([list count] > 0) {
            self.hasNextData = YES;
        }
    } fail:nil];
}

- (void)loadNextData
{
    if (!self.hasNextData)
        return;
    if (self.isLoading)
        return;
    
    self.isLoading = YES;
    TIMFriendPendencyRequest *req = TIMFriendPendencyRequest.new;
    req.numPerPage = self.numPerPage;
    
    if (self.timestamp > 0) {
        req.seq = self.origSeq;
    } else {
        req.seq = self.seq;
        self.origSeq = self.seq;
    }
    req.timestamp = self.timestamp;
    req.type = TIM_PENDENCY_COME_IN;
    
    [[TIMFriendshipManager sharedInstance] getPendencyList:req succ:^(TIMFriendPendencyResponse *pendencyResponse) {
        NSMutableArray *list = @[].mutableCopy;
        for (TIMFriendPendencyItem *item in pendencyResponse.pendencies) {
            TCommonPendencyCellData *data = [[TCommonPendencyCellData alloc] initWithPendency:item];
            [list addObject:data];
        }
        self.isLoading = NO;
        if ([list count] > 0) {
            self.seq = pendencyResponse.seq;
            self.timestamp = pendencyResponse.timestamp;
            self.dataList  = [self.dataList arrayByAddingObjectsFromArray:list];
            self.hasNextData = YES;
        } else {
            self.hasNextData = NO;
        }
    } fail:nil];
}

@end
