//
//  TUIGroupPinPageViewController.m
//  TUIChat
//
//  Created by Tencent on 2024/05/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupPinPageViewController.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUIGroupPinCell.h"
#import "TUIMessageDataProvider.h"


@interface TUIGroupPinPageViewController() <UITableViewDelegate,UITableViewDataSource>

@end

@implementation TUIGroupPinPageViewController


- (instancetype)init {
    self = [super init];
    if (self) {        
        self.tableview.backgroundColor = TUIChatDynamicColor(@"chat_pop_group_pin_back_color", @"#F9F9F9");
        self.customArrowView.backgroundColor = TUIChatDynamicColor(@"chat_pop_group_pin_back_color", @"#F9F9F9");
        self.bottomShadow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];

        [self addSingleTapGesture];
    }
    return self;
}

- (void)addSingleTapGesture {
    // When clicking on the shadow, the page disappears
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.view addGestureRecognizer:singleTap];
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tableview.frame = CGRectMake(0, self.tableview.frame.origin.y, self.view.frame.size.width, 60);
        self.customArrowView.frame = CGRectMake(0, CGRectGetMaxY(self.tableview.frame), self.view.frame.size.width, self.customArrowView.frame.size.height);
        self.bottomShadow.frame = CGRectMake(0, CGRectGetMaxY(self.customArrowView.frame), self.view.frame.size.width, 0);
    }completion:^(BOOL finished) {
        if (finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
    
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc] init];
        _tableview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableview.delegate = self;
        _tableview.dataSource = self;
        [_tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _tableview.showsVerticalScrollIndicator = NO;
        _tableview.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_tableview];
        UIView *herderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        _tableview.tableHeaderView = herderView;
    }
    return _tableview;
}

- (UIView *)customArrowView {
    if (!_customArrowView) {
        _customArrowView = [[UIView alloc] initWithFrame:CGRectMake(0, _tableview.frame.size.height, _tableview.frame.size.width, 100)];
        [self.view addSubview:_customArrowView];
        UIView *arrowBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        arrowBackgroundView.backgroundColor = [UIColor clearColor];
        arrowBackgroundView.layer.cornerRadius = 5;
        [_customArrowView addSubview:arrowBackgroundView];
        _customArrowView.clipsToBounds = YES;
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        arrow.image = TUIChatBundleThemeImage(@"chat_pop_group_pin_up_arrow_img", @"chat_up_arrow_icon");
        [arrowBackgroundView addSubview:arrow];
            
        [arrowBackgroundView  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_customArrowView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(arrowBackgroundView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];

    }
    return _customArrowView;
}

- (UIView *)bottomShadow {
    if (!_bottomShadow) {
        _bottomShadow = [[UIView alloc] init];
        _bottomShadow.userInteractionEnabled = NO;
        [self.view addSubview:_bottomShadow];
    }
    return _bottomShadow;
}
#pragma mark - group pin

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIGroupPinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[TUIGroupPinCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = [UIColor systemGroupedBackgroundColor];
    V2TIMMessage *msg = self.groupPinList[indexPath.row];
    TUIMessageCellData * cellData = [TUIMessageDataProvider getCellData:msg];
    [cell fillWithData:cellData];
    __weak __typeof(self) weakSelf = self;
    cell.cellView.removeButton.hidden = !self.canRemove;
    cell.cellView.onClickRemove = ^(V2TIMMessage *originMessage) {
        if (weakSelf.onClickRemove) {
            weakSelf.onClickRemove(originMessage);
        }
    };
    
    cell.cellView.onClickCellView = ^(V2TIMMessage *originMessage) {
        if (weakSelf.onClickCellView) {
            weakSelf.onClickCellView(originMessage);
        }
        [weakSelf singleTap:nil];
    };
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupPinList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat contentH = 62;
    CGFloat padding = 0;
    return contentH + padding;
}

@end
