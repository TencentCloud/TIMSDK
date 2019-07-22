#import <UIKit/UIKit.h>
#import "TUIContactActionCellData.h"
#import "TCommonCell.h"
#import "TUnReadView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactActionCell : TCommonTableViewCell

@property UIImageView *avatarView;
@property UILabel *titleLabel;
@property TUnReadView *unRead;

@property (readonly) TUIContactActionCellData *actionData;

- (void)fillWithData:(TUIContactActionCellData *)contactData;

@end

NS_ASSUME_NONNULL_END
