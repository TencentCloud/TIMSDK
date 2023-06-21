
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TUIBubbleMessageCell_Minimalist.h>
#import "TUIFaceMessageCellData_Minimalist.h"

@interface TUIFaceMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist
/**
 *  表情图像视图
 *  存放[动画表情]所对应的图像资源。
 *
 *  Image view for the resource of emticon
 */
@property(nonatomic, strong) UIImageView *face;

@property TUIFaceMessageCellData_Minimalist *faceData;

- (void)fillWithData:(TUIFaceMessageCellData_Minimalist *)data;
@end
