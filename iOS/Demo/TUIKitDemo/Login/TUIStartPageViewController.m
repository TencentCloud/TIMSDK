//
//  TUIStartPageViewController.m
//  TUIKitDemo
//
//  Created by Tencent on 2023/8/1.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIStartPageViewController.h"
#import "TUIThemeManager.h"
#import "TUIGlobalization.h"
#import <Masonry/Masonry.h>
@interface TUIStartPageViewController ()
@property (strong, nonatomic) UIView *containerLogoView;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UILabel *mainLabel;

@end

@implementation TUIStartPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = TUIDemoDynamicColor(@"launch_page_color", @"#F3F4F5");;
    [self.view addSubview:self.containerLogoView];
    [self.containerLogoView addSubview:self.logoImageView];
    [self.containerLogoView addSubview:self.mainLabel];
    self.logoImageView.image = TUIDemoDynamicImage(@"launch_page_logo_img", [UIImage imageNamed:TUIDemoImagePath(@"launch_page_logo")]);
    self.mainLabel.text = NSLocalizedString(@"TUIStartPageTitle", nil);
    
    [self.containerLogoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerLogoView.mas_top);
        make.centerX.mas_equalTo(self.containerLogoView);
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(80);
    }];
    [self.mainLabel sizeToFit];
    [self.mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.logoImageView.mas_bottom).mas_offset(10);
        make.width.mas_equalTo(self.mainLabel.frame.size.width);
        make.height.mas_equalTo(self.mainLabel.frame.size.height);
        make.bottom.mas_equalTo(self.containerLogoView.mas_bottom);
        make.centerX.mas_equalTo(self.logoImageView);
    }];
    

}

- (UIView *)containerLogoView {
    if(!_containerLogoView){
        _containerLogoView = [[UIView alloc] init];
    }
    return _containerLogoView;
}
- (UIImageView *)logoImageView {
    if(!_logoImageView){
        _logoImageView = [[UIImageView alloc] init];
    }
    return _logoImageView;
}
- (UILabel *)mainLabel {
    if(!_mainLabel) {
        _mainLabel = [[UILabel alloc] init];
        _mainLabel.font = [UIFont boldSystemFontOfSize:35];
        _mainLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _mainLabel;;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
