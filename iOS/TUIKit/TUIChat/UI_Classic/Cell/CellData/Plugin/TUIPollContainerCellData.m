//
//  TUIPollContainerCellData.m
//  TUIChat
//
//  Created by xia on 2023/1/5.
//

#import "TUIPollContainerCellData.h"
#import "TUICore.h"

@implementation TUIPollContainerCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TUIPollContainerCellData *cellData = [[TUIPollContainerCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.msgID = message.msgID;
    cellData.message = message;
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    if ([[self.class parseBusinessID:message] isEqualToString:@"group_poll"]) {
        return TUIKitLocalizableString(TUIPollDisplayString);
    }
    return nil;
}

// Override, the size of bubble content.
- (CGSize)contentSize {
    self.businessID = [self.class parseBusinessID:self.message];
    
    self.cachedSize = self.childViewController.view.frame.size;
    return self.childViewController.view.frame.size;
}

- (UIViewController *)childViewController {
    if (_childViewController != nil) {
        return _childViewController;
    }

    if ([self.businessID isEqualToString:@"group_poll"]) {
        NSDictionary *param = @{
            TUICore_TUIPollService_GetPollViewControllerMethod_MessageKey: self.innerMessage
        };
        UIViewController *vc = (UIViewController *)[TUICore callService:TUICore_TUIPollService
                                                                 method:TUICore_TUIPollService_GetPollViewControllerMethod
                                                                  param:param];
        _childViewController = vc;
        return _childViewController;
    }
    
    return _childViewController;
}

+ (NSString *)parseBusinessID:(V2TIMMessage *)message {
    NSData *customData = message.customElem.data;
    NSDictionary *dict = [TUITool jsonData2Dictionary:customData];
    return dict[@"businessID"];
}

@end
