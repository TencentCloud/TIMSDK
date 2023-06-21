//
//  TUIConversationForwardSelectCell_Minimalist.h
//  TUIConversation
//
//  Created by wyl on 2023/1/31.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationCell_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationForwardSelectCell_Minimalist : UITableViewCell
@property(nonatomic, strong) UIButton *selectButton;
@property(nonatomic, strong) UIImageView *avatarView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) TUIConversationCellData *selectData;

- (void)fillWithData:(TUIConversationCellData *)selectData;

@end

NS_ASSUME_NONNULL_END
