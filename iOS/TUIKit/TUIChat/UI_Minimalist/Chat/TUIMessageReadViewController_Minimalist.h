//
//  TUIMessageReadViewController_Minimalist.h
//  TUIChat
//
//  Created by xia on 2022/3/10.
//

#import <UIKit/UIKit.h>
#import "TUIMessageCellData.h"
#import "TUIChatDefine.h"
#import "TUIMessageCell_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIMessageDataProvider_Minimalist;
@interface TUIMessageReadViewController_Minimalist : UIViewController
@property (nonatomic, strong) Class alertCellClass;
@property (nonatomic, strong) TUIMessageCellData *alertViewCellData;
@property (nonatomic, assign) CGRect originFrame;

@property (copy, nonatomic) void (^viewWillShowHandler)(TUIMessageCell *alertView);
@property (copy, nonatomic) void (^viewDidShowHandler)(TUIMessageCell *alertView);

- (instancetype)initWithCellData:(TUIMessageCellData *)data
                    dataProvider:(TUIMessageDataProvider_Minimalist *)dataProvider
           showReadStatusDisable:(BOOL)showReadStatusDisable
                 c2cReceiverName:(NSString *)name
               c2cReceiverAvatar:(NSString *)avatarUrl;
@end



NS_ASSUME_NONNULL_END
