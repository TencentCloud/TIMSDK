//
//  VideoCallCell.h
//  TUIKitDemo
//
//  Created by xcoderliu on 9/29/19.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TUITextMessageCell.h"
#import "VideoCallCellData.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^videoCellClickBlock)(void);

@interface VideoCallCell : TUITextMessageCell
- (void)fillWithData:(VideoCallCellData *)data;
@property (nonatomic,copy,nullable)videoCellClickBlock videlClick;
@end

NS_ASSUME_NONNULL_END
