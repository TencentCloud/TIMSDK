//
//  V2TUIMessageController.h
//  Pods
//
//  Created by harvy on 2020/12/30.
//

#import "TUIMessageController.h"
#import "TUIKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface V2TUIMessageController : TUIMessageController

/**
 * 高亮文本，在搜索场景下，匹配该关键字后cell会高亮显示
 */
@property (nonatomic, copy) NSString *hightlightKeyword;

/**
 * 定位消息，打开消息列表之后会定位到当前消息，适用于消息搜索场景下点击后的跳转
 */
@property (nonatomic, strong) V2TIMMessage *locateMessage;

@end

NS_ASSUME_NONNULL_END
