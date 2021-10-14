/**
 * Module: TUILiveMsgListCell
 *
 * Function: 消息Cell
 */

#import <UIKit/UIKit.h>
#import "TUILiveMsgModel.h"
@class TRTCLiveUserInfo;
typedef void (^TCLiveTopClick)(void);

/**
 *  TUILiveMsgListCell 类说明：
 *  用户消息列表cell，用于展示消息信息
 */
@interface TUILiveMsgListCell : UITableViewCell
/**
 *  刷新cell内容信息
 */
- (void)refreshWithModel:(TUILiveMsgModel *)msgModel;

/**
 *  通过msgModel 获取消息列表每行的内容信息，通过返回的AttributedString计算cell的高度
 */
+ (NSAttributedString *)getAttributedStringFromModel:(TUILiveMsgModel *)msgModel;

@end


//观众列表
#define IMAGE_SIZE  35
#define IMAGE_SPACE 5
/**
 *  TCAudienceListCell 类说明：
 *  房间观众list cell，用于展示观众信息
 */
@interface TCAudienceListCell : UITableViewCell
/**
 *  通过msgModel刷新观众信息
 */
-(void)refreshWithModel:(TRTCLiveUserInfo *)msgModel;
@end
