//
//  TUIMediaCollectionCell.m
//  TUIChat
//
//  Created by xiangzhang on 2021/11/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMediaCollectionCell_Minimalist.h"

@implementation TUIMediaCollectionCell_Minimalist
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)fillWithData:(TUIMessageCellData *)data {
    return;
}

@end
