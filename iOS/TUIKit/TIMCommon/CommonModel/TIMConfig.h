//
//  TIMConfig.h
//  Pods
//
//  Created by cologne on 2023/3/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TUICore/TUIConfig.h>
#import "TIMCommonModel.h"
#import "TIMDefine.h"

@class TUIFaceCellData;
@class TUIFaceGroup;

NS_ASSUME_NONNULL_BEGIN

@interface TIMConfig : NSObject

+ (TIMConfig *)defaultConfig;
/**
 *
 * The list of emojis in the input box of the chat interface
 * It should be noted that the emoticons in TUIKit are copyrighted. The purchased IM service does not include the right to use the emoticons. Please replace
 * them with your own emoticons when you go online, otherwise you will face legal risks.
 */
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *faceGroups;

/**
 * 
 * The list of emoticons displayed after long-pressing the message on the chat interface
 */
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *chatPopDetailGroups;


@property(nonatomic, assign) BOOL enableMessageBubble;

+ (BOOL)isClassicEntrance;
@end

NS_ASSUME_NONNULL_END
