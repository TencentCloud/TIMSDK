//
//  TUICancelAccountViewController.m
//  TUIKitDemo
//
//  Created by wyl on 2022/2/9.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUICancelAccountViewController.h"
#import "TUINaviBarIndicatorView.h"
#import "TUIThemeManager.h"
#import <Masonry/Masonry.h>
#import "TCLoginModel.h"

#import "TUIKit.h"
#import "TUILoginCache.h"
#import "AppDelegate+Push.h"

@interface TUICancelAccountViewController ()
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) UIImageView *headImg;
@property (nonatomic, strong) UIImageView *headDecorationImg;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *unsubscribeButton;
@property TCLoginModel *loginModel;


@end

@implementation TUICancelAccountViewController

//MARK: init
- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginModel = [TCLoginModel sharedInstance];
    [self setupView];
    [self applyLayout];
    [self applyData];
    
}
- (void)setupView {
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:NSLocalizedString(@"TUIKitAboutUsCloseAccount", nil)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    self.view.backgroundColor = TUICoreDynamicColor(@"controller_bg_color", @"#F2F3F5");
    
    self.headImg = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self.view addSubview:self.headImg];
    self.headImg.contentMode = UIViewContentModeScaleAspectFit;
    
    
    self.headDecorationImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancelAccountDecoration"]];
    [self.view addSubview:self.headDecorationImg];

    self.descriptionLabel = [[UILabel alloc] init];
    [self.view addSubview:self.descriptionLabel];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:11];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    NSString *descriptionText = [NSString stringWithFormat:    NSLocalizedString(@"TUIKitAboutUsCloseAccountDescribe", nil),loginUser];
    NSMutableAttributedString  *setString = [[NSMutableAttributedString alloc] initWithString:descriptionText];
    [setString  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [descriptionText length])];
    [self.descriptionLabel  setAttributedText:setString];
    self.descriptionLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    
    self.unsubscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.unsubscribeButton];
    self.unsubscribeButton.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0];
    self.unsubscribeButton.layer.cornerRadius = 8;
    [self.unsubscribeButton setTitle:NSLocalizedString(@"TUIKitAboutUsCloseAccount", nil) forState:UIControlStateNormal];
    [self.unsubscribeButton setTitleColor:[UIColor colorWithRed:250/255.0 green:81/255.0 blue:81/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    self.unsubscribeButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC" size:18];
    [self.unsubscribeButton addTarget:self action:@selector(unsubscribeAction) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)applyLayout {
    
    [self.headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(72);
        make.height.mas_equalTo(72);
        make.top.mas_equalTo(self.view.mas_top).offset(NavBar_Height+StatusBar_Height+100);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.headDecorationImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@26);
        make.height.equalTo(@26);
        make.right.mas_equalTo(self.headImg.mas_right).mas_offset(2.5);
        make.bottom.mas_equalTo(self.headImg.mas_bottom).mas_offset(5);
    }];
    
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImg.mas_bottom).offset(24);
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
    }];
    
    [self.unsubscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descriptionLabel.mas_bottom).offset(80);
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@46);
    }];
    self.headImg.layer.cornerRadius  = 72 * 0.5;
    self.headImg.layer.masksToBounds = YES;
    
}

- (void)applyData {
    NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
    if (loginUser.length > 0) {
        @weakify(self)
        [[V2TIMManager sharedInstance] getUsersInfo:@[loginUser] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            @strongify(self)
            V2TIMUserFullInfo *profile = infoList.firstObject;
            if (profile && profile.faceURL) {
                [self.headImg sd_setImageWithURL:[NSURL URLWithString:profile.faceURL]];
            }
        } fail:nil];
    }
}
//MARK: action
- (void)unsubscribeAction {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"TUIKitAboutUsCloseAccountAlterMsg", nil) preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self)weakSelf = self;
    [ac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"TUIKitAboutUsCloseAccountAlterAction1", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf unsubscribeNetRequset];
    }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:TUIKitLocalizableString(Cancel) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

//MARK: NetWork
/*
 注销请求->成功后退出登录&并清除token和phone信息->回到登录页
 */
- (void)unsubscribeNetRequset {
    dispatch_async(dispatch_get_main_queue(), ^{
        // please insert your code
        [self logOut];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TUITool makeToast:@"please insert your code" duration:3];
        });
    });
}

- (void)logOut {
    [[TUIKit sharedInstance] logout:^{
        [AppDelegate.sharedInstance push_unregisterIfLogouted];
        [self _didLogoutInSettingController];
        [self _clearToken];
    } fail:^(int code, NSString *msg) {
        NSLog(@"退出登录失败");
    }];
}

- (void)_didLogoutInSettingController {
    [[TUILoginCache sharedInstance] logout];
    
    UIViewController *loginVc = [AppDelegate.sharedInstance getLoginController];
    self.view.window.rootViewController = loginVc;
}

- (void)_clearToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Key_UserInfo_Phone"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Key_UserInfo_Token"];
}
@end
