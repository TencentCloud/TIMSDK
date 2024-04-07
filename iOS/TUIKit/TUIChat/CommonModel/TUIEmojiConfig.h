//
//  TUIEmojiConfig.h
//  TUIEmojiPlugin
//
//  Created by wyl on 2023/11/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TIMCommon/TIMCommonModel.h>
NS_ASSUME_NONNULL_BEGIN
@class TUIFaceGroup;

@interface TUIEmojiConfig : NSObject
+ (TUIEmojiConfig *)defaultConfig;

/**
 * The list of emojis in the input box of the chat interface
 * It should be noted that the emoticons in TUIKit are copyrighted. The purchased IM service does not include the right to use the emoticons. Please replace
 * them with your own emoticons when you go online, otherwise you will face legal risks.
 * The yellow face emoji is copyrighted by Tencent Cloud. To use it, authorization is required. Please contact us through the following link.
 * https://cloud.tencent.com/document/product/269/59590
 */
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *faceGroups;

/**
 * The list of emoticons displayed after long-pressing the message on the chat interface
 */
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *chatPopDetailGroups;

@property(nonatomic, strong) NSArray<TUIFaceGroup *> *chatContextEmojiDetailGroups;

- (void)appendFaceGroup:(TUIFaceGroup *)faceGroup;

@end

@interface TUIEmojiConfig (defaultFace)
- (TUIFaceGroup *)getChatPopMenuRecentQueue;
- (void)updateEmojiGroups;
- (void)updateRecentMenuQueue:(NSString *)faceName;
@end


NS_ASSUME_NONNULL_END
