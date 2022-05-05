/******************************************************************************
  *
  *  本文件声明了 TUIMemberCell 类。
  *  消息已读成员列表组件 cell，包含头像视图、昵称视图
  *
  ******************************************************************************/

#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMemberCellData;
@interface TUIMemberCell : TUICommonTableViewCell

- (void)fillWithData:(TUIMemberCellData *)cellData;

@end

NS_ASSUME_NONNULL_END
