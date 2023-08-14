//
//  TUIRepliesDetailViewController.h
//  TUIChat
//
//  Created by wyl on 2022/4/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>
#import "TUIBaseMessageControllerDelegate_Minimalist.h"
#import "TUIChatConversationModel.h"
#import "TUIChatFlexViewController.h"
#import "TUIInputController_Minimalist.h"
#import "TUIMessageDataProvider.h"

@class TUIMessageDataProvider;

NS_ASSUME_NONNULL_BEGIN

@interface TUIRepliesDetailViewController_Minimalist : TUIChatFlexViewController

- (instancetype)initWithCellData:(TUIMessageCellData *)data conversationData:(TUIChatConversationModel *)conversationData;

@property(nonatomic, weak) id<TUIBaseMessageControllerDelegate_Minimalist> delegate;
@property(nonatomic, strong) V2TIMMergerElem *mergerElem;
@property(nonatomic, copy) dispatch_block_t willCloseCallback;
@property(nonatomic, strong) TUIInputController_Minimalist *inputController;
@property(nonatomic, strong) TUIMessageDataProvider *parentPageDataProvider;

@end

NS_ASSUME_NONNULL_END
