//
//  ChatViewController.h
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/22.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ConversationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatViewController : NSViewController
@property (weak) IBOutlet NSTextField *groupMember;
@property (unsafe_unretained) IBOutlet NSTextView *msgTextView;
@property (weak) IBOutlet NSTextField *msgTextFeild;

@property (nonatomic, strong) TConversationCellData *conversation;
@end

NS_ASSUME_NONNULL_END
