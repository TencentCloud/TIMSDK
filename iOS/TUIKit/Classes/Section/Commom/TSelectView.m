//
//  TSelectView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TSelectView.h"
#import "THeader.h"


@interface TSelectView ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation TSelectView
- (id)init
{
    self = [super init];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    self.backgroundColor = TSelectView_Background_Color;
    _tableView = [[UITableView alloc] init];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [self addSubview:_tableView];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *array = _data[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TSelectView_Row_Heihgt;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return 0;
    }
    else{
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = TSelectView_Header_Background_Color;
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section == 0){
        if(_delegate && [_delegate respondsToSelector:@selector(selectView:didSelectRowAtIndex:)]){
            [_delegate selectView:self didSelectRowAtIndex:indexPath.row];
        }
    }
    else{
    }
    [self hide];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:TSelectView_ReuseId];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TSelectView_ReuseId];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    NSMutableArray *array = _data[indexPath.section];
    cell.textLabel.text = array[indexPath.row];
    if(indexPath.section == 1){
        cell.textLabel.textColor = [UIColor redColor];
    }
    else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

- (void)setData:(NSMutableArray *)data
{
    _data = [NSMutableArray array];
    [_data addObject:data];
    NSMutableArray *cancelArray = [NSMutableArray arrayWithObject:@"取消"];
    [_data addObject:cancelArray];
    [_tableView reloadData];
    [_tableView layoutIfNeeded];
    CGSize size = [_tableView sizeThatFits:[UIScreen mainScreen].bounds.size];
    
    CGFloat height = 20;
    for (NSMutableArray *array in _data) {
        height += array.count * TSelectView_Row_Heihgt;
    }
    _tableView.frame = CGRectMake(0, Screen_Height - height, Screen_Width, height);
}

- (void)showInWindow:(UIWindow *)window
{
    [window addSubview:self];
    CGRect frame = _tableView.frame;
    CGRect newFrame = frame;
    frame.origin.y = self.frame.size.height;
    _tableView.frame = frame;
    __weak typeof(self) ws = self;
    self.alpha = 0;;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.tableView.frame = newFrame;
        ws.alpha = 1;
    } completion:nil];
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [self hide];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]){
        return NO;
    }
    return YES;
}

- (void)hide
{
    CGRect frame = _tableView.frame;
    frame.origin.y = self.frame.size.height;
    __weak typeof(self) ws = self;
    
    self.alpha = 1;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        ws.alpha = 0;
        ws.tableView.frame = frame;
    } completion:^(BOOL finished) {
        if([ws superview]){
            [ws removeFromSuperview];
        }
    }];
}
@end
