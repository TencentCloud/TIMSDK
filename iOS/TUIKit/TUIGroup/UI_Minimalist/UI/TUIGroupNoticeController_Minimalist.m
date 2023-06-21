//
//  TUIGroupNoticeController.m
//  TUIGroup
//
//  Created by harvy on 2022/1/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupNoticeController_Minimalist.h"
#import <TUICore/TUIThemeManager.h>
#import "TUIGroupNoticeDataProvider.h"

@interface TUIGroupNoticeController_Minimalist ()

@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, weak) UIButton *rightButton;
@property(nonatomic, strong) TUIGroupNoticeDataProvider *dataProvider;

@end

@implementation TUIGroupNoticeController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
    [self.view addSubview:self.textView];

    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitleColor:TIMCommonDynamicColor(@"nav_title_text_color", @"#000000") forState:UIControlStateNormal];
    [rightBtn setTitleColor:TIMCommonDynamicColor(@"nav_title_text_color", @"#000000") forState:UIControlStateSelected];
    [rightBtn setTitle:TIMCommonLocalizableString(Edit) forState:UIControlStateNormal];
    [rightBtn setTitle:TIMCommonLocalizableString(Done) forState:UIControlStateSelected];
    [rightBtn sizeToFit];
    [rightBtn addTarget:self action:@selector(onClickRight:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton = rightBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.rightButton.hidden = YES;

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = TIMCommonLocalizableString(TUIKitGroupNotice);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    __weak typeof(self) weakSelf = self;
    self.dataProvider.groupID = self.groupID;
    [self.dataProvider getGroupInfo:^{
      weakSelf.textView.text = weakSelf.dataProvider.groupInfo.notification;
      weakSelf.textView.editable = NO;
      weakSelf.rightButton.hidden = !weakSelf.dataProvider.canEditNotice;
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.textView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.dataProvider.canEditNotice && self.textView.text.length == 0) {
        [self onClickRight:self.rightButton];
    }
}

- (void)onClickRight:(UIButton *)button {
    if (button.isSelected) {
        self.textView.editable = NO;
        [self.textView resignFirstResponder];
        [self updateNotice];
    } else {
        self.textView.editable = YES;
        [self.textView becomeFirstResponder];
    }
    button.selected = !button.isSelected;
}

- (void)updateNotice {
    __weak typeof(self) weakSelf = self;
    [self.dataProvider updateNotice:self.textView.text
                           callback:^(int code, NSString *desc) {
                             if (code != 0) {
                                 [TUITool makeToastError:code msg:desc];
                                 return;
                             }
                             if (weakSelf.onNoticeChanged) {
                                 weakSelf.onNoticeChanged();
                             }
                           }];
}

- (UITextView *)textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
        _textView.textColor = TIMCommonDynamicColor(@"form_title_color", @"#000000");
        _textView.font = [UIFont systemFontOfSize:17];
    }
    return _textView;
}

- (TUIGroupNoticeDataProvider *)dataProvider {
    if (_dataProvider == nil) {
        _dataProvider = [[TUIGroupNoticeDataProvider alloc] init];
    }
    return _dataProvider;
}

@end
