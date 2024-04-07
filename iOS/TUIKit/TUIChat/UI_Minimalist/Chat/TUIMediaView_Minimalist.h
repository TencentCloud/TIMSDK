
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *  This file declares the logic used to realize the sliding display of pictures and videos
 */
#import <UIKit/UIKit.h>

@import ImSDK_Plus;

@interface TUIMediaView_Minimalist : UIView
@property(nonatomic, copy) dispatch_block_t onClose;

/**
 * Setting thumb, for animating
 */
- (void)setThumb:(UIImageView *)thumb frame:(CGRect)frame;

/**
 * Setting the current message that needs to be displayed. MediaView will automatically load the before and after messages of the current message for display,
 * mainly used in the scene of the normal message list
 */
- (void)setCurMessage:(V2TIMMessage *)curMessage;

/**
 * Setting the current and all messages to be displayed, mainly used in the scenario of merge-forward message lists
 */
- (void)setCurMessage:(V2TIMMessage *)curMessage allMessages:(NSArray *)messages;
@end
