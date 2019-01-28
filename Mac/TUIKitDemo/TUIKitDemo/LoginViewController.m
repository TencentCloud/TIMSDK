//
//  ViewController.m
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/22.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import "LoginViewController.h"
#import "ConversationController.h"
#import "AppDelegate.h"
#import "ImSDK.h"

@interface LoginViewController()<TIMConnListener,TIMUserStatusListener,TIMRefreshListener>

@end

@implementation LoginViewController
{
    NSArray  *_userNames;
    NSArray  *_userSigs;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userNames = @[identifier1,identifier2,identifier3,identifier4];
    _userSigs  = @[userSig1,userSig2,userSig3,userSig4];
    [_userBox removeAllItems];
    [_userBox addItemsWithObjectValues:_userNames];
    
    TIMSdkConfig *sdkConfig = [[TIMSdkConfig alloc] init];
    sdkConfig.sdkAppId = sdkAppid;
    sdkConfig.accountType = sdkAccountType;
    sdkConfig.connListener = self;
    [[TIMManager sharedInstance] initSdk:sdkConfig];
}

- (IBAction)login:(NSButton *)sender {
    if (![_userNames containsObject:_userBox.stringValue]) {
        [self alert:@"账号错误！" informativeText:@"请选择测试账号"];
        return;
    }
    NSString *sig = [_userSigs objectAtIndex:[_userNames indexOfObject:_userBox.stringValue]];
    if ([sig isEqualToString:@""]) {
        [self alert:@"userSig错误！" informativeText:@"请前往IM控制台 -> 开发者辅助工具生成对应测试账号的userSig，然后在工程 AppDelegate.h 配置"];
        return;
    }
    __weak typeof(self) ws = self;
    //[self getUserSig:_userBox.stringValue callback:^(NSString *sig) {
        TIMLoginParam *param = [TIMLoginParam new];
        param.identifier = self.userBox.stringValue;
        param.userSig = sig;
        [[TIMManager sharedInstance] login:param succ:^{
            ConversationController *vc = [[ConversationController alloc] initWithNibName:@"ConversationController" bundle:nil];
            [ws presentViewControllerAsModalWindow:vc];
        } fail:^(int code, NSString *msg) {
            [ws alert:@"登录失败！" informativeText:[NSString stringWithFormat:@"code:%d msg:%@ ,请检查sdkAppId 和 userSig 是否正确配置",code,msg]];
        }];
    //}];
}

- (void)alert:(NSString *)text informativeText:(NSString *)informativeText{
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"知道了"];
    [alert setMessageText:text];
    [alert setInformativeText:informativeText];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        //to do
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)getUserSig:(NSString *)user callback:(void (^)(NSString *sig))callback
{
    NSURL *url = [NSURL URLWithString:@""];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    request.HTTPMethod = @"POST";
    NSDictionary *param = @{@"cmd":@"open_account_svc", @"sub_cmd":@"fetch_sig", @"id":user};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        int code = [[result objectForKey:@"error_code"] intValue];
        NSString *sig = nil;
        if(code == 0){
            sig = [result objectForKey:@"user_sig"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(sig);
        });
    }];
    [task resume];
}

@end
