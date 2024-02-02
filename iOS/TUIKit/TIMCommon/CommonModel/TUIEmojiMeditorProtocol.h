//
//  TUIEmojiMeditorProtocol.h
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/11/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIMDefine.h"
#import "TIMCommonModel.h"
@class V2TIMMessage;
@class TUIFaceGroup;

NS_ASSUME_NONNULL_BEGIN

@protocol TUIEmojiMeditorProtocol <NSObject>
- (void)updateEmojiGroups;
- (id)getFaceGroup;
- (void)appendFaceGroup:(TUIFaceGroup *)faceGroup;
- (id)getChatPopDetailGroups;
- (id)getChatContextEmojiDetailGroups;
- (id)getChatPopMenuRecentQueue;
- (void)updateRecentMenuQueue:(NSString *)faceName;
@end

NS_ASSUME_NONNULL_END
