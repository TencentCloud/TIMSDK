//
//  TUIRepliesDetailViewController.h
//  TUIChat
//
//  Created by wyl on 2022/4/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUIBaseMessageControllerDelegate.h"
#import "TUIChatConversationModel.h"
#import "TUIInputController.h"

@class TUIMessageDataProvider;

NS_ASSUME_NONNULL_BEGIN

@interface TUIRepliesDetailViewController : UIViewController

- (instancetype)initWithCellData:(TUIMessageCellData *)data conversationData:(TUIChatConversationModel *)conversationData;

@property(nonatomic, weak) id<TUIBaseMessageControllerDelegate> delegate;
@property(nonatomic, strong) V2TIMMergerElem *mergerElem;
@property(nonatomic, copy) dispatch_block_t willCloseCallback;
@property(nonatomic, strong) TUIInputController *inputController;
@property(nonatomic, strong) TUIMessageDataProvider *parentPageDataProvider;

@end

NS_ASSUME_NONNULL_END
