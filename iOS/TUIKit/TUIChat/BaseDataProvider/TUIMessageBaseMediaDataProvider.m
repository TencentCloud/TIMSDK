//
//  TUIMessageSearchDataProvider.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//

#import "TUIMessageBaseMediaDataProvider.h"
#import "TUIMessageBaseDataProvider+ProtectedAPI.h"

/**
 * 消息拉取方式
 * Message pull method
 */
typedef NS_ENUM(NSInteger, TUIMediaLoadType){
    TUIMediaLoadType_Older                 = 1,
    TUIMediaLoadType_Newer                 = 2,
    TUIMediaLoadType_Older_And_Newer       = 3,
};

@interface TUIMessageBaseMediaDataProvider()
@property (nonatomic) TUIChatConversationModel* conversationModel;
@property (nonatomic, assign) TUIMediaLoadType loadType;
@property (nonatomic, strong) V2TIMMessage* loadMessage;
@property (nonatomic, assign) BOOL isOlderNoMoreMsg;
@property (nonatomic, assign) BOOL isNewerNoMoreMsg;
@end

@implementation TUIMessageBaseMediaDataProvider

- (instancetype)initWithConversationModel:(nullable TUIChatConversationModel *)conversationModel {
    self = [super initWithConversationModel:conversationModel];
    if (self) {
        self.conversationModel = conversationModel;
        self.isOlderNoMoreMsg = NO;
        self.isNewerNoMoreMsg = NO;
        self.pageCount = 20;
        self.medias = [NSMutableArray array];
    }
    return self;
}

- (void)loadMediaWithMessage:(V2TIMMessage *)curMessage {
    self.loadMessage = curMessage;
    self.loadType = TUIMediaLoadType_Older_And_Newer;
    /**
     * 消息处于发送中的时候，通过消息拉取前后视频（图片）消息会异常，这里暂时只展示当前消息
     * When the message is being sent, an exception will occur when pulling the before and after video (picture) messages through the current message. Only the current message is displayed here for the time being.
     */
    if (self.loadMessage.status != V2TIM_MSG_STATUS_SENDING) {
        [self loadMedia];
    } else {
        NSMutableArray *medias = self.medias;
        TUIMessageCellData *data = [self.class getMediaCellData:self.loadMessage];
        if (data) {
            [medias addObject:data];
            self.medias = medias;
        }
    }
}

- (void)loadOlderMedia{
    if (self.loadMessage.status != V2TIM_MSG_STATUS_SENDING) {
        TUIMessageCellData *firstData = (TUIMessageCellData *)self.medias.firstObject;
        self.loadMessage = firstData.innerMessage;
        self.loadType = TUIMediaLoadType_Older;
        [self loadMedia];
    }
}

- (void)loadNewerMedia{
    if (self.loadMessage.status != V2TIM_MSG_STATUS_SENDING) {
        TUIMessageCellData *lastData = (TUIMessageCellData *)self.medias.lastObject;
        self.loadMessage = lastData.innerMessage;
        self.loadType = TUIMediaLoadType_Newer;
        [self loadMedia];
    }
}

- (void)loadMedia{
    if (!self.loadMessage) {
        return;
    }
    if (![self isNeedLoad:self.loadType]) {
        return;
    }
    @weakify(self)
    [self loadMediaMessage:self.loadMessage loadType:self.loadType SucceedBlock:^(NSArray<V2TIMMessage *> * _Nonnull olders, NSArray<V2TIMMessage *> * _Nonnull newers) {
        @strongify(self)
        NSMutableArray *medias = self.medias;
        for (V2TIMMessage *msg in olders) {
            TUIMessageCellData *data = [self.class getMediaCellData:msg];
            if (data) {
                [medias insertObject:data atIndex:0];
            }
        }
        if(self.loadType == TUIMediaLoadType_Older_And_Newer) {
            TUIMessageCellData *data = [self.class getMediaCellData:self.loadMessage];
            if (data) {
                [medias addObject:data];;
            }
        }
        for (V2TIMMessage *msg in newers) {
            TUIMessageCellData *data = [self.class getMediaCellData:msg];
            if (data) {
                [medias addObject:data];
            }
        }
        self.medias = medias;
    } FailBlock:^(int code, NSString *desc) {
        NSLog(@"load message failed!");
    }];
}

- (BOOL)isNeedLoad:(TUIMediaLoadType)type {
    if ((TUIMediaLoadType_Older == type && self.isOlderNoMoreMsg) ||
        (TUIMediaLoadType_Newer == type && self.isNewerNoMoreMsg) ||
        (TUIMediaLoadType_Older_And_Newer == type && self.isOlderNoMoreMsg && self.isNewerNoMoreMsg)) {
        return NO;
    }
    return YES;
}

- (void)loadMediaMessage:(V2TIMMessage *)loadMsg
                loadType:(TUIMediaLoadType)type
            SucceedBlock:(void(^)(NSArray<V2TIMMessage *> * _Nonnull olders, NSArray<V2TIMMessage *> * _Nonnull newers))SucceedBlock
               FailBlock:(V2TIMFail)FailBlock {
    if(self.isLoadingData) {
        FailBlock(ERR_SUCC, @"loading");
        return;
    }
    self.isLoadingData = YES;
    
    dispatch_group_t group = dispatch_group_create();
    __block NSArray *olders = @[];
    __block NSArray *newers = @[];
    __block BOOL isOldLoadFail = NO;
    __block BOOL isNewLoadFail = NO;
    __block int failCode = 0;
    __block NSString *failDesc = nil;
    
    /**
     * 以定位消息为起点，加载最旧的20条富媒体消息
     * Loading the oldest 20 media messages starting from the positioning message
     */
    if(TUIMediaLoadType_Older == type || TUIMediaLoadType_Older_And_Newer == type)
    {
        dispatch_group_enter(group);
        V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
        option.getType = V2TIM_GET_LOCAL_OLDER_MSG;
        option.count = self.pageCount;
        option.groupID = self.conversationModel.groupID;
        option.userID = self.conversationModel.userID;
        option.lastMsg = loadMsg;
        option.messageTypeList = @[@(V2TIM_ELEM_TYPE_IMAGE), @(V2TIM_ELEM_TYPE_VIDEO)];
        [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
            olders = msgs?:@[];
            if (olders.count < self.pageCount) {
                self.isOlderNoMoreMsg = YES;
            }
            dispatch_group_leave(group);
        } fail:^(int code, NSString *desc) {
            isOldLoadFail = YES;
            failCode = code;
            failDesc = desc;
            dispatch_group_leave(group);
        }];
    }

    /**
     * 以定位消息为起点，加载最新的20条富媒体消息
     * Load the latest 20 rich media messages starting from the positioning message
     */
    if(TUIMediaLoadType_Newer == type || TUIMediaLoadType_Older_And_Newer == type)
    {
        dispatch_group_enter(group);
        V2TIMMessageListGetOption *option = [[V2TIMMessageListGetOption alloc] init];
        option.getType = V2TIM_GET_LOCAL_NEWER_MSG;
        option.count = self.pageCount;
        option.groupID = self.conversationModel.groupID;
        option.userID = self.conversationModel.userID;
        option.lastMsg = loadMsg;
        option.messageTypeList = @[@(V2TIM_ELEM_TYPE_IMAGE), @(V2TIM_ELEM_TYPE_VIDEO)];
        [V2TIMManager.sharedInstance getHistoryMessageList:option succ:^(NSArray<V2TIMMessage *> *msgs) {
            newers = msgs?:@[];
            if (newers.count < self.pageCount) {
                self.isNewerNoMoreMsg = YES;
            }
            dispatch_group_leave(group);
        } fail:^(int code, NSString *desc) {
            isNewLoadFail = YES;
            failCode = code;
            failDesc = desc;
            dispatch_group_leave(group);
        }];
    }
    @weakify(self)
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self)
        self.isLoadingData = NO;
        if (isOldLoadFail || isNewLoadFail) {
            dispatch_async(dispatch_get_main_queue(), ^{
                FailBlock(failCode, failDesc);
            });
        }
        self.isFirstLoad = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            SucceedBlock(olders, newers);
        });
    });
}

- (void)removeCache {
    [self.medias removeAllObjects];
    self.isNewerNoMoreMsg = NO;
    self.isOlderNoMoreMsg = NO;
    self.isFirstLoad = YES;
}


+ (TUIMessageCellData *)getMediaCellData:(V2TIMMessage *)message {
    // subclass override required
    return nil;
}
@end
