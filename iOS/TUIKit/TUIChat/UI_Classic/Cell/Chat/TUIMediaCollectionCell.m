//
//  TUIMediaCollectionCell.m
//  TUIChat
//
//  Created by xiangzhang on 2021/11/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMediaCollectionCell.h"

@interface TUIMediaCollectionCell()<V2TIMAdvancedMsgListener>

@end
@implementation TUIMediaCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self registerTUIKitNotification];
    }
    return self;
}

- (void)fillWithData:(TUIMessageCellData *)data {
    return;
}

- (void)registerTUIKitNotification {
    [[V2TIMManager sharedInstance] addAdvancedMsgListener:self];
}
@end
