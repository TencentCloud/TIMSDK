
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TUIBubbleMessageCell.h>
#import <TIMCommon/TUIMessageCell.h>
#import "TUIFaceMessageCellData.h"

@interface TUIFaceMessageCell : TUIBubbleMessageCell

/**
 *  表情图像视图
 *  存放[动画表情]所对应的图像资源。
 *
 *  Image view for the resource of emticon
 */
@property(nonatomic, strong) UIImageView *face;

@property TUIFaceMessageCellData *faceData;

- (void)fillWithData:(TUIFaceMessageCellData *)data;
@end
