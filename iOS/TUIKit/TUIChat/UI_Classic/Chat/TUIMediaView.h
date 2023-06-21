
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  本文件声明了用于实现图片视频左右滑动展示的逻辑
 *  This file declares the logic used to realize the sliding display of pictures and videos
 */
#import <UIKit/UIKit.h>

@import ImSDK_Plus;

@interface TUIMediaView : UIView
@property(nonatomic, copy) dispatch_block_t onClose;

/**
 * 微缩图，主要用于动画的展示
 * Setting thumb, for animating
 */
- (void)setThumb:(UIImageView *)thumb frame:(CGRect)frame;

/**
 * 当前需要展示的消息，MediaView 会自动加载当前消息的前后消息展示，主要用于正常消息列表的场景
 * Setting the current message that needs to be displayed. MediaView will automatically load the before and after messages of the current message for display,
 * mainly used in the scene of the normal message list
 */
- (void)setCurMessage:(V2TIMMessage *)curMessage;

/**
 * 当前和全部需要展示的消息，主要用于合并转发的消息列表的场景
 * Setting the current and all messages to be displayed, mainly used in the scenario of merge-forward message lists
 */
- (void)setCurMessage:(V2TIMMessage *)curMessage allMessages:(NSArray *)messages;
@end
