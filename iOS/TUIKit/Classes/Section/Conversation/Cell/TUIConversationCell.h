//
//  TUIConversationCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TCommonCell.h"
#import "TUIConversationCellData.h"
#import "TUnReadView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationCell : TCommonTableViewCell

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) TUnReadView *unReadView;

@property (atomic, strong) TUIConversationCellData *convData;
- (void)fillWithData:(TUIConversationCellData *)convData;

@end

NS_ASSUME_NONNULL_END
