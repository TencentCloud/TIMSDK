
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import "TUIMediaCollectionCell.h"
#import "TUIVideoMessageCellData.h"

@interface TUIVideoCollectionCell : TUIMediaCollectionCell

- (void)fillWithData:(TUIVideoMessageCellData *)data;

- (void)stopVideoPlayAndSave;

- (void)reloadAllView;
@end
