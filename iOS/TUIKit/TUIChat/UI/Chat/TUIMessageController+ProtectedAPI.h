//
//  TUIMessageController+ProtectedAPI.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/7/8.
//

#import "TUIMessageController.h"
#import "TUIMessageDataProvider.h"
#import "TUIChatConversationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageController ()<TUIMessageDataProviderDataSource>

@property (nonatomic, strong) TUIMessageDataProvider *messageDataProvider;
@property (nonatomic, strong) TUIChatConversationModel *conversationData;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)onNewMessage:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
