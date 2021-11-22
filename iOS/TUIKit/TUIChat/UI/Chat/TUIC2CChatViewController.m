//
//  TUIC2CChatViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/6/17.
//

#import "TUIC2CChatViewController.h"
#import "TUIBaseChatViewController+ProtectedAPI.h"
#import "TUILinkCellData.h"
#import "TUIMessageDataProvider.h"

@interface TUIC2CChatViewController ()

@end

@implementation TUIC2CChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Override Methods
- (NSString *)forwardTitleWithMyName:(NSString *)nameStr {
    return [NSString stringWithFormat:TUIKitLocalizableString(TUIKitRelayChatHistoryForSomebodyFormat), self.conversationData.title, nameStr];
}

- (void)inputController:(TUIInputController *)inputController didSelectMoreCell:(TUIInputMoreCell *)cell
{
    [super inputController:inputController didSelectMoreCell:cell];
    
    NSString *key = cell.data.key;
    if([key isEqualToString:TUIInputMoreCellKey_Link]) {  // 自定义消息
        NSString *text = TUIKitLocalizableString(TUIKitWelcome);
        NSString *link = @"https://cloud.tencent.com/document/product/269/3794";
        NSError *error = nil;
        NSDictionary *param = @{BussinessID: BussinessID_TextLink, @"text":text, @"link":link};
        NSData *data = [NSJSONSerialization dataWithJSONObject:param options:0 error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error", [self class]);
            return;
        }
        V2TIMMessage *message = [TUIMessageDataProvider getCustomMessageWithJsonData:data];
        [self sendMessage:message];
    }
}

@end
