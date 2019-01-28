//
//  MsgTableCellView.h
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/23.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConversationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MsgTableCellView : NSTableCellView
-(void)setHeader:(NSImage *)image msg:(NSString *)msg subMsg:(NSString *)subMsg time:(NSString *)time;
@end

NS_ASSUME_NONNULL_END
