/******************************************************************************
 *
 *  本文件声明了用于实现图片视频左右滑动展示的逻辑
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>

@import ImSDK_Plus;

@interface TUIMediaView : UIView
@property (nonatomic, copy) dispatch_block_t onClose;
/// 微缩图，主要用于动画的展示
- (void)setThumb:(UIImageView *)thumb frame:(CGRect)frame;
/// 当前需要展示的消息，MediaView 会自动加载当前消息的前后消息展示，主要用于正常消息列表
- (void)setCurMessage:(V2TIMMessage *)curMessage;
/// 当前和全部需要展示的消息，主要用于合并转发的消息列表
- (void)setCurMessage:(V2TIMMessage *)curMessage allMessages:(NSArray *)messages;
@end
