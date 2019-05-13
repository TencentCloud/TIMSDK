//
//  TFaceMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/10/8.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TMessageCell.h"


@interface TFaceMessageCellData : TMessageCellData
@property (nonatomic, assign) NSInteger groupIndex;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *faceName;
@end

@interface TFaceMessageCell : TMessageCell
@property (nonatomic, strong) UIImageView *face;
@end
