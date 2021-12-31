//
//  TUIMediaCollectionCell.m
//  TUIChat
//
//  Created by xiangzhang on 2021/11/22.
//

#import "TUIMediaCollectionCell.h"

@implementation TUIMediaCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)fillWithData:(TUIMessageCellData *)data {
    return;
}

@end
