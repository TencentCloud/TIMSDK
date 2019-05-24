//
//  TAddC2CController.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TAddC2CController.h"
#import "TAddCell.h"
#import "TAddHeaderView.h"
#import "THeader.h"
#import "TAddHelper.h"

@interface TAddC2CController () <UITableViewDelegate, UITableViewDataSource, TAddIndexViewDelegate, TAddIndexViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *formatData;
@property (nonatomic, strong) TAddCellData *selectedData;
@property (nonatomic, strong) UIButton *rightButton;
@end

@implementation TAddC2CController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupViews];
}


- (void)setupViews
{
    self.title = @"添加会话";
    self.parentViewController.title = @"添加会话";
    self.view.backgroundColor = TAddC2CController_Background_Color;
    
    //left
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(leftBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.parentViewController.navigationItem.leftBarButtonItem = leftItem;
    
    
    //right
    _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [_rightButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;
    //_rightButton.enabled = NO;
    
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, StatusBar_Height + NavBar_Height, self.view.frame.size.width - 2 * 20, 55)];
    _textField.placeholder = @"输入用户ID";
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_textField];
    
    _line = [[UIView alloc] initWithFrame:CGRectMake(0, _textField.frame.origin.y + _textField.frame.size.height, self.view.frame.size.width, TAddC2CController_Line_Height)];
    _line.backgroundColor = TAddC2CController_Line_Color;
    [self.view addSubview:_line];
    
    CGFloat originY = _line.frame.origin.y + _line.frame.size.height;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width, Screen_Height - originY)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[TAddHeaderView class] forHeaderFooterViewReuseIdentifier:TAddHeaderView_ReuseId];
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    
    _indexView = [[TAddIndexView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - TAddIndexView_Width, 0, TAddIndexView_Width, self.view.frame.size.height)];
    _indexView.delegate = self;
    _indexView.dataSource = self;
    [self.view addSubview:_indexView];
    [_indexView setSelectionIndex:0];
}

- (void)setupData
{
    _formatData = [NSMutableArray array];
    _formatData = [TAddHelper arrayWithFirstLetterFormat:_data];
}

- (void)leftBarButtonClick:(UIButton *)sender
{
    [_textField resignFirstResponder];
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelInAddC2CController:)]){
        [_delegate didCancelInAddC2CController:self];
    }
}


- (void)rightBarButtonClick:(UIButton *)sender
{
    [_textField resignFirstResponder];
    if(![_textField.text isEqualToString:@""])
    {
        if(_delegate && [_delegate respondsToSelector:@selector(addC2CController:didCreateChat:)]){
            [_delegate addC2CController:self didCreateChat:_textField.text];
        }
    }
    else{
        if(_selectedData){
            if(_delegate && [_delegate respondsToSelector:@selector(addC2CController:didCreateChat:)]){
                [_delegate addC2CController:self didCreateChat:_selectedData.name];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _formatData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = _formatData[section];
    NSMutableArray *array = dict[TLetter_Value];
    return array.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TAddHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:TAddHeaderView_ReuseId];
    [header setLetter:_formatData[section][TLetter_Key]];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [TAddHeaderView getHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TAddCell getHeight];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [_indexView tableView:tableView willDisplayHeaderView:view forSection:section];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    [_indexView tableView:tableView didEndDisplayingHeaderView:view forSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TAddCell *cell = [tableView dequeueReusableCellWithIdentifier:TAddCell_ReuseId];
    if(!cell){
        cell = [[TAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TAddCell_ReuseId];
    }
    NSDictionary *dict = _formatData[indexPath.section];
    NSMutableArray *array = dict[TLetter_Value];
    [cell setData:array[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    for (NSInteger s = 0; s < _formatData.count; ++s) {
        NSDictionary *dict = _formatData[s];
        NSMutableArray *array = dict[TLetter_Value];
        for (NSInteger i = 0; i < array.count; ++i) {
            TAddCellData *item = array[i];
            if(s == indexPath.section && i == indexPath.row){
                if(item.state == TAddCell_State_Selected){
                    item.state = TAddCell_State_UnSelect;
                    _selectedData = nil;
                }
                else if(item.state == TAddCell_State_UnSelect){
                    item.state = TAddCell_State_Selected;
                    _selectedData = item;
                }
            }
            else{
                item.state = TAddCell_State_UnSelect;
            }
        }
    }
    if(_selectedData == nil){
        _rightButton.enabled = NO;
    }
    else{
        _rightButton.enabled = YES;;
    }
    
    [_tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_indexView scrollViewDidScroll:scrollView];
}










#pragma mark - TAddIndexView
- (NSArray<NSString *> *)sectionIndexTitles{
    NSMutableArray *resultArray = [NSMutableArray array];
    for (NSDictionary *dict in _formatData) {
        NSString *title = dict[TLetter_Key];
        if (title) {
            [resultArray addObject:title];
        }
    }
    return resultArray;
}

//当前选中组
- (void)selectedSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

//将指示器视图添加到当前视图上
- (void)addIndicatorView:(UIView *)view {
    [self.view addSubview:view];
}
@end
