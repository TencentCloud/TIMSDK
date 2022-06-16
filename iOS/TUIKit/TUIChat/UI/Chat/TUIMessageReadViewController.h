/******************************************************************************
 *
 * 腾讯云通讯服务界面组件 TUIKIT - 消息已读成员列表组件
 *
 * 本文件主要声明了点击群聊消息的已读 label 后，跳转到已读成员列表的控制器类
 *
 * TUIMessageReadSelectView 类定义了已读列表中的类似 tab 视图。目前仅在 TUIMessageReadViewController 中使用。
 * TUIMessageReadSelectViewDelegate 回调点击视图事件。目前由 TUIMessageReadViewController 实现，完成已读、未读列表的切换。
 *
 * TUIMessageReadViewController 类实现了已读成员列表的 UI 和逻辑。
 * TUIMessageReadViewControllerDelegate 回调点击成员列表 cell 事件。
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kMemberCellReuseId = @"kMemberCellReuseId";

typedef NS_ENUM(NSInteger, TUIMessageReadViewTag) {
    TUIMessageReadViewTagUnknown = 0,   // unknown
    TUIMessageReadViewTagRead,          // read group members
    TUIMessageReadViewTagUnread,        // unread group members
    TUIMessageReadViewTagReadDisable,   // disable read group members
    TUIMessageReadViewTagC2C,           // c2c member
};

@class TUIMessageReadSelectView;
@protocol TUIMessageReadSelectViewDelegate <NSObject>
@optional
- (void)messageReadSelectView:(TUIMessageReadSelectView *)view
             didSelectItemTag:(TUIMessageReadViewTag)tag;
@end

@interface TUIMessageReadSelectView : UIView
@property (nonatomic, weak) id<TUIMessageReadSelectViewDelegate> delegate;
@property (nonatomic, assign) BOOL selected;

- (instancetype)initWithTitle:(NSString *)title
                      viewTag:(TUIMessageReadViewTag)tag
                     selected:(BOOL)selected;

@end


@class TUIMessageDataProvider;
@interface TUIMessageReadViewController : UIViewController

- (instancetype)initWithCellData:(TUIMessageCellData *)data
                    dataProvider:(TUIMessageDataProvider *)dataProvider
           showReadStatusDisable:(BOOL)showReadStatusDisable
                 c2cReceiverName:(NSString *)name
               c2cReceiverAvatar:(NSString *)avatarUrl;
@end



NS_ASSUME_NONNULL_END
