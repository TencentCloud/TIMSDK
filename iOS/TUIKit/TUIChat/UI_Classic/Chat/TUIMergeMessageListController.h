//
//  TUIMergeMessageListController.h
//  Pods
//
//  Created by harvy on 2020/12/9.
//

#import <UIKit/UIKit.h>
#import <TIMCommon/TIMDefine.h>
#import "TUIBaseMessageControllerDelegate.h"
#import "TUIChatConversationModel.h"
#import "TUIMessageDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMergeMessageListController : UITableViewController

@property (nonatomic, weak) id<TUIBaseMessageControllerDelegate> delegate;
@property (nonatomic, strong) V2TIMMergerElem *mergerElem;
@property (nonatomic, copy) dispatch_block_t willCloseCallback;
@property (nonatomic, strong) TUIChatConversationModel *conversationData;
@property (nonatomic, strong) TUIMessageDataProvider *parentPageDataProvider;

@end

NS_ASSUME_NONNULL_END
