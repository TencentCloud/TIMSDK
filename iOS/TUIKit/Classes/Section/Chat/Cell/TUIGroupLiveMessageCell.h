//
//  TUIGroupLiveMessageCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by coddyliu on 2020/9/14.
//

#import "TUIMessageCell.h"
#import "TUIGroupLiveMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupLiveMessageCell : TUIMessageCell
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *statusLabel;
@property(nonatomic, strong) UILabel *tagLabel;
@property(nonatomic, strong) UIImageView *roomCoverImageView;

@property TUIGroupLiveMessageCellData *customData;
- (void)fillWithData:(TUIGroupLiveMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
