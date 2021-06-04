//
//  TUIConversationSelectController.h
//  Pods
//
//  Created by harvy on 2020/12/8.
//

#import <UIKit/UIKit.h>
@class TUIConversationCellData;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUIConversationSelectCompletHandler)(BOOL);
typedef void(^TUIConversationSelectCallback)(NSArray<TUIConversationCellData *> *, TUIConversationSelectCompletHandler);

@interface TUIConversationSelectController : UIViewController

@property (nonatomic, copy) TUIConversationSelectCallback callback;
+ (instancetype)showIn:(UIViewController *)presentVC;

@end

NS_ASSUME_NONNULL_END
