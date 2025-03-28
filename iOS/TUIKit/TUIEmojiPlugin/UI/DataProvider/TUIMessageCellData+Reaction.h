//
//  TUIMessageCellData+Reaction.h
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/11/27.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import <TIMCommon/TUIMessageCellData.h>
#import "TUIEmojiReactDataProvider.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIReactValueChangedCallback)(NSArray<TUIReactModel *> *tagsArray);
@interface TUIMessageCellData (Reaction)
@property(nonatomic, strong) TUIEmojiReactDataProvider *reactdataProvider;
@property(nonatomic, copy) TUIReactValueChangedCallback reactValueChangedCallback;

- (void)setupReactDataProvider;
//- (void)loadReactList;
- (void)updateReactClick:(NSString *)faceName;
- (void)addReactByEmojiKey:(NSString *)emojiKey;
- (void)delReactByEmojiKey:(NSString *)emojiKey;
- (void)addReactModel:(TUIReactModel *)model;
- (void)delReactModel:(TUIReactModel *)model;
@end
NS_ASSUME_NONNULL_END
