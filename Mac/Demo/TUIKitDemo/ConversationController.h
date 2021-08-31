//
//  ConversationController.h
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/23.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TConvType) {
    TConv_Type_C2C      = 1,
    TConv_Type_Group    = 2,
    TConv_Type_System   = 3,
};


@interface TConversationCellData : NSObject
@property (nonatomic, strong) NSString *convId;
@property (nonatomic, assign) TConvType convType;
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, assign) int unRead;
@end

@interface ConversationController : NSViewController
@property (weak) IBOutlet NSTableView *msgTableView;

@end

NS_ASSUME_NONNULL_END
