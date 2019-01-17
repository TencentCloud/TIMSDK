//
//  TSystemMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TMessageCell.h"

@interface TSystemMessageCellData : TMessageCellData
@property (nonatomic, strong) NSString *content;
@end

@interface TSystemMessageCell : TMessageCell
@property (nonatomic, strong) UILabel *content;
@end
