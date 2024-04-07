
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import "TUIFaceMessageCellData.h"

@interface TUIFaceMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist
/**
 *  Image view for the resource of emticon
 */
@property(nonatomic, strong) UIImageView *face;

@property TUIFaceMessageCellData *faceData;

- (void)fillWithData:(TUIFaceMessageCellData *)data;
@end
