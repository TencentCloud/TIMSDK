
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TUIImageMessageCellData.h"
#import "TUIMediaCollectionCell.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIMediaImageCell
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIImageCollectionCell : TUIMediaCollectionCell

- (void)fillWithData:(TUIImageMessageCellData *)data;
- (void)reloadAllView;
@end
