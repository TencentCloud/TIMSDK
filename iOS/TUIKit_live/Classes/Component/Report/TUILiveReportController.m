//
//  TUILiveReport.m
//  Pods
//
//  Created by harvy on 2020/9/24.
//

#import "TUILiveReportController.h"
#import "TUILiveUserProfile.h"
#import "THelper.h"

@interface TUILiveReportController ()


/// 被举报者id
@property (nonatomic, copy) NSString *beReportedId;

@end

@implementation TUILiveReportController

- (void)reportUser:(NSString *)userId
{
    self.beReportedId = userId;
    if (userId == nil || userId.length == 0) {
        return;
    }
    
    NSArray *reportType = @[@"违法违规", @"色情低俗", @"标题党、封面党、骗点击", @"未成年人不适当行为",@"制售假冒伪劣商品", @"滥用作品", @"泄露我的隐私"];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:@"请选择分类，分类越准，处理越快" preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    for (NSString *title in reportType) {
        [vc addAction: [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf notifyResult:@"举报成功，我们将在24小时内进行处理"];
            [weakSelf doReport:title completion:nil];
        }]];
    }
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [TUILiveReportController.findCurrentShowingViewController presentViewController:vc animated:YES completion:nil];
}

- (void)doReport:(NSString *)type completion:(void(^)(int, NSString *, NSDictionary *))completion
{
    if ([NSThread isMainThread]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [weakSelf doReport:type completion:completion];
        });
        return;
    }
    
    NSDictionary *params = @{@"userid" : self.beReportedId?:@"", @"hostuserid" : TUILiveUserProfile.getLoginUserInfo.userID?:@"", @"reason":type?:@""};
    NSData *data = [TUILiveReportController dictionary2JsonData:params];
    if (data == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(-1, @"参数不合法(userid、hostuserid)", nil);
            }
        });
        return;
    }
    NSString *url = @"http://demo.vod2.myqcloud.com/lite/report_user";
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setHTTPBody:data];
    [request setTimeoutInterval:30];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
//            [self notifyResult:[NSString stringWithFormat:@"举报失败(%zd)", error.code]];
            return;
        }
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [TUILiveReportController jsonData2Dictionary:responseString];
        int errCode = -1;
        NSString *message = @"";
        NSDictionary *dataDict = nil;
        if (resultDict) {
            if (resultDict[@"code"]) {
                errCode = [resultDict[@"code"] intValue];
            }
            
            if (resultDict[@"message"]) {
                message = resultDict[@"message"];
            }
            
            if (200 == errCode && resultDict[@"data"]) {
                dataDict = resultDict[@"data"];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(errCode, message, dataDict);
            }
        });
    }];
    [task resume];
}

- (void)notifyResult:(NSString *)result
{
    if (![NSThread isMainThread]) {
        __weak typeof(self)  weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notifyResult:result];
        });
        return;
    }
    [THelper makeToast:result];
}


#pragma mark - Utils

+ (UIViewController *)findCurrentShowingViewController {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [self findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
}

+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) {
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
    } else if ([vc isKindOfClass:[UINavigationController class]]){
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
    } else {
        currentShowingVC = vc;
    }
    return currentShowingVC;
}

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict
{
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        return data;
    }
    return nil;
}

+ (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData
{
    if (jsonData == nil) {
        return nil;
    }
    NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return nil;
    }
    return dic;
}



@end
