
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TUIMessageCell_Minimalist.h>
#import "TUIImageMessageCellData_Minimalist.h"

@interface TUIImageMessageCell_Minimalist : TUIMessageCell_Minimalist

@property(nonatomic, strong) UIImageView *thumb;

@property(nonatomic, strong) UILabel *progress;

@property TUIImageMessageCellData_Minimalist *imageData;

- (void)fillWithData:(TUIImageMessageCellData_Minimalist *)data;
@end
