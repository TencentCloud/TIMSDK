//
//  TUIGroupNoteContainerCellData.m
//  TUIChat
//
//  Created by xia on 2023/1/5.
//

#import "TUIGroupNoteContainerCellData.h"
#import "TUICore.h"

@implementation TUIGroupNoteContainerCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data options:NSJSONReadingAllowFragments error:nil];
    TUIGroupNoteContainerCellData *cellData = [[TUIGroupNoteContainerCellData alloc] initWithDirection:message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming];
    cellData.msgID = message.msgID;
    cellData.message = message;
    return cellData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    if ([[self.class parseBusinessID:message] isEqualToString:@"group_note"]) {
        return TUIKitLocalizableString(TUIGroupNoteDisplayString);
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

    if ([self.businessID isEqualToString:@"group_note"])  {
        NSDictionary *param = @{
            TUICore_TUIGroupNoteService_GetGroupNotePreviewVCMethod_MessageKey: self.innerMessage
        };
        UIViewController *vc = (UIViewController *)[TUICore callService:TUICore_TUIGroupNoteService
                                                                 method:TUICore_TUIGroupNoteService_GetGroupNotePreviewVCMethod
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
