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
 * 聊天界面输入框的表情列表
 * 需要注意的是， TUIKit 里面的表情包都是有版权限制的，购买的 IM 服务不包括表情包的使用权，请在上线的时候替换成自己的表情包，否则会面临法律风险
 *
 * The list of emojis in the input box of the chat interface
 * It should be noted that the emoticons in TUIKit are copyrighted. The purchased IM service does not include the right to use the emoticons. Please replace
 * them with your own emoticons when you go online, otherwise you will face legal risks.
 */
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *faceGroups;

/**
 * 聊天界面上长按消息后显示的表情列表
 * The list of emoticons displayed after long-pressing the message on the chat interface
 */
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *chatPopDetailGroups;


@property(nonatomic, assign) BOOL enableMessageBubble;

@end

NS_ASSUME_NONNULL_END
