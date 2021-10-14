/**
 * Module: TCMsgBarrageView
 *
 * Function: 弹幕
 */

#import <UIKit/UIKit.h>
#import "TUILiveMsgModel.h"

/**
 *  TUILiveMsgBarrageView 类说明：
 *  当前类主要是展示用户发送的弹幕消息，里面可以自定义弹幕的效果
 */

@interface TUILiveMsgBarrageView : UIView
/**
 *  记录当前TUILiveMsgBarrageView最后一个弹幕View，通过弹幕View frame 判断下一个弹幕消息显示在哪个TUILiveMsgBarrageView
 */
@property(nonatomic,retain) UIView *lastAnimateView;
/**
 *  默认头像，如果消息发送者没有头像时显示。
 */
@property(nonatomic, strong) UIImage *defaultAvatarImage;

/**
 *  给弹幕view 发送msgModel消息
 *
 *  @param msgModel 弹幕消息
 */
- (void)bulletNewMsg:(TUILiveMsgModel *)msgModel;

/**
 *  停止动画，移除动画view
 */
- (void)stopAnimation;

@end
