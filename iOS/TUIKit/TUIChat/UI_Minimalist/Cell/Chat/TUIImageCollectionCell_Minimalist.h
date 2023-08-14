
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TUIImageMessageCellData.h"
#import "TUIMediaCollectionCell_Minimalist.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                     TUIMediaImageCell_Minimalist
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIImageCollectionCell_Minimalist : TUIMediaCollectionCell_Minimalist

- (void)fillWithData:(TUIImageMessageCellData *)data;
@end
