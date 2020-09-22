/******************************************************************************
 *
 *  本文件声明了 TUISystemMessageCell 类。
 *  本文件负责实现入群小灰条的功能，同时也能进一步扩展为所有操作者为单人的群组消息单元。
 *  即本文件能够实现将操作者昵称蓝色高亮，并提供蓝色高亮部分的响应接口。
 *
 ******************************************************************************/

#import "TUISystemMessageCell.h"
#import "TUIJoinGroupMessageCellData.h"
NS_ASSUME_NONNULL_BEGIN

@class TUIJoinGroupMessageCell;

@protocol TJoinGroupMessageCellDelegate <NSObject>

/**
 *  点击昵称标签后的响应回调
 *  您可以通过该委托实现：跳转到昵称对应用户的资料界面。
 */
- (void)didTapOnNameLabel:(TUIJoinGroupMessageCell *)cell;

- (void)didTapOnSecondNameLabel:(TUIJoinGroupMessageCell *)cell;

- (void)didTapOnRestNameLabel:(TUIJoinGroupMessageCell *)cell withIndex:(NSInteger)index;

@end

@interface TUIJoinGroupMessageCell : TUISystemMessageCell

/**
 *  加入群聊对应的数据源，存储了用户昵称和用户 ID。
 */
@property TUIJoinGroupMessageCellData *joinData;

/**
 *  负责实现 TJoinGroupMessageCellDelegate 的委托类，和 messageCell 中的 delegate 进行区分。
 */
@property (nonatomic,weak) id<TJoinGroupMessageCellDelegate> joinGroupDelegate;

@end



NS_ASSUME_NONNULL_END
