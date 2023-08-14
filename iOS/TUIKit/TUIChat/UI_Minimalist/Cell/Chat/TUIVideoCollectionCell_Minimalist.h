
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TUIMediaCollectionCell_Minimalist.h"
#import "TUIVideoMessageCellData.h"

@interface TUIVideoCollectionCell_Minimalist : TUIMediaCollectionCell_Minimalist

- (void)fillWithData:(TUIVideoMessageCellData *)data;

- (void)stopVideoPlayAndSave;

@end
