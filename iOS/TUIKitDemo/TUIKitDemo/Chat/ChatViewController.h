/** 腾讯云IM Demo 聊天视图
 *  本文件实现了聊天视图
 *  在用户需要收发群组、以及其他用户消息时提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */
#import <UIKit/UIKit.h>
#import "TUIChatController.h"

@interface ChatViewController : UIViewController
@property (nonatomic, strong) TUIConversationCellData *conversationData;
@end
