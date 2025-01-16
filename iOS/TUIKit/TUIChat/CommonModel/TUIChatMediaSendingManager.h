//
//  TUIChatMediaSendingManager.h
//  TUIChat
//
//  Created by yiliangwang on 2025/1/6.
//  Copyright © 2025 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatMediaTask : NSObject
@property (nonatomic, strong) TUIMessageCellData* placeHolderCellData;
@property (nonatomic, copy) NSString *msgID;
@property (nonatomic, copy) NSString *conversationID;
@end

@interface TUIChatMediaSendingManager : NSObject
@property (nonatomic, strong) NSMutableDictionary<NSString *, TUIChatMediaTask *> *tasks;
@property (nonatomic, strong) NSHashTable<UIViewController *> *mediaSendingControllers;
+ (instancetype)sharedInstance;
- (void)addMediaTask:(TUIChatMediaTask *)task forKey:(NSString *)key;
- (void)updateProgress:(float)progress forKey:(NSString *)key;
- (void)removeMediaTaskForKey:(NSString *)key;
- (NSMutableArray<TUIChatMediaTask *> *)findPlaceHolderListByConversationID:(NSString *)conversationID;
- (void)addCurrentVC:(UIViewController *)vc;
- (void)removeCurrentVC:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
