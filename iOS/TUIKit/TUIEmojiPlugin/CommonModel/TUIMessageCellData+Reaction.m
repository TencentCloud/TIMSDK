//
//  TUIMessageCellData+Reaction.m
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/11/27.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUIMessageCellData+Reaction.h"
#import <objc/runtime.h>
#import "TUIReactModel.h"
#import "TUIReactUtil.h"

@implementation TUIMessageCellData (Reaction)

- (TUIEmojiReactDataProvider *)reactdataProvider {
    return objc_getAssociatedObject(self, @"reactdataProvider");
}


- (void)setReactdataProvider:(TUIEmojiReactDataProvider *)reactdataProvider {
    objc_setAssociatedObject(self, @"reactdataProvider", reactdataProvider, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setReactValueChangedCallback:(TUIReactValueChangedCallback)reactValueChangedCallback {
    objc_setAssociatedObject(self, @"reactValueChangedCallback", reactValueChangedCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);

}
- (TUIReactValueChangedCallback)reactValueChangedCallback {
    return objc_getAssociatedObject(self, @"reactValueChangedCallback");

}

- (void)setupReactDataProvider {
    if (self.status == Msg_Status_Fail) {
        return;
    }
    self.reactdataProvider = [[TUIEmojiReactDataProvider alloc] init];
    self.reactdataProvider.msgId = self.innerMessage.msgID;
    __weak typeof(self) weakSelf = self;
    self.reactdataProvider.changed = ^(NSArray<TUIReactModel *> * _Nonnull tagsArray, NSMutableDictionary * _Nonnull tagsMap) {
        if (weakSelf.reactValueChangedCallback) {
            weakSelf.reactValueChangedCallback(tagsArray);
        }
    };
}

- (void)addReactModel:(TUIReactModel *)model {
    [self addReactByEmojiKey:model.emojiKey];
}

- (void)delReactModel:(TUIReactModel *)model {
    [self delReactByEmojiKey:model.emojiKey];
}

- (void)addReactByEmojiKey:(NSString *)emojiKey {
    [self.reactdataProvider addMessageReaction:self.innerMessage
                                    reactionID:emojiKey
                                          succ:^{
                                          }
                                          fail:^(int code, NSString *desc){
        NSString* errMsg = [TUITool convertIMError:code msg:desc];

        [TUITool makeToast:errMsg];
    }];
}
- (void)delReactByEmojiKey:(NSString *)emojiKey {
    [self.reactdataProvider removeMessageReaction:self.innerMessage
        reactionID:emojiKey
        succ:^{
        }
        fail:^(int code, NSString *desc) {
        NSString *errMsg = [TUITool convertIMError:code msg:desc];
        [TUITool makeToast:errMsg];
    }];
}

- (void)updateReactClick:(NSString *)faceName {
    TUIEmojiReactDataProvider *reactdataProvider = self.reactdataProvider;
    TUIReactModel * targetModel = [reactdataProvider  getCurrentReactionIDInMap:faceName];
    if (targetModel) {
        if (targetModel.reactedByMyself) {
            //del
            [self delReactByEmojiKey:targetModel.emojiKey];
        }
        else {
            //add
            [self addReactByEmojiKey:targetModel.emojiKey];
        }
    }
    else {
        // new model
        [self addReactByEmojiKey:faceName];
    }
}
@end
