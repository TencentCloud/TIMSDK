//
//  TDeleteMemberController.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TDeleteMemberController.h"
#import "TAddCell.h"
#import "TAddHeaderView.h"
#import "THeader.h"
#import "TAddHelper.h"
#import "TAddCollectionCell.h"
#import "TPickView.h"
#import "TGroupMemberCell.h"
@import ImSDK;

@implementation TDeleteMemberResult
@end


@interface TDeleteMemberController () <UITableViewDelegate, UITableViewDataSource, TAddIndexViewDelegate, TAddIndexViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *formatData;
@property (nonatomic, strong) NSMutableArray *selectedData;
@property (nonatomic, strong) UIButton *rightButton;
@end

@implementation TDeleteMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupData];
}


- (void)setupViews
{
    self.title = @"删除成员";
    self.parentViewController.title = @"删除成员";
    self.view.backgroundColor = TDeleteMemberController_Background_Color;
    
    //left
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftButton addTarget:self action:@selector(leftBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.parentViewController.navigationItem.leftBarButtonItem = leftItem;
    
    
    //right
    _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    [_rightButton addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.parentViewController.navigationItem.rightBarButtonItem = rightItem;
    _rightButton.enabled = NO;
    
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout.minimumLineSpacing = TAddCollectionCell_Margin;
    _flowLayout.minimumInteritemSpacing = TAddCollectionCell_Margin;
    _flowLayout.headerReferenceSize = CGSizeMake(TAddCollectionCell_Margin, 0);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, StatusBar_Height + NavBar_Height, 0, 60) collectionViewLayout:_flowLayout];
    [_collectionView registerClass:[TAddCollectionCell class] forCellWithReuseIdentifier:TAddCollectionCell_ReuseId];
    _collectionView.collectionViewLayout = _flowLayout;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_collectionView];
    
    CGFloat textOriginX = _collectionView.frame.origin.x + _collectionView.frame.size.width + TDeleteMemberController_Margin;
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(textOriginX, StatusBar_Height + NavBar_Height, self.view.frame.size.width - textOriginX, 60)];
    _textField.placeholder = @"输入用户ID";
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_textField];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _textField.frame.origin.y + _textField.frame.size.height, self.view.frame.size.width, TDeleteMemberController_Line_Height)];
    line.backgroundColor = TDeleteMemberController_Line_Color;
    [self.view addSubview:line];
    
    CGFloat originY = line.frame.origin.y + line.frame.size.height;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, originY, self.view.frame.size.width, Screen_Height - originY)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[TAddHeaderView class] forHeaderFooterViewReuseIdentifier:TAddHeaderView_ReuseId];
    [self.view addSubview:_tableView];
    
    
    _indexView = [[TAddIndexView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - TAddIndexView_Width, 0, TAddIndexView_Width, self.view.frame.size.height)];
    _indexView.delegate = self;
    _indexView.dataSource = self;
    [self.view addSubview:_indexView];
    [_indexView setSelectionIndex:0];
}

- (void)setupData
{
    __weak typeof(self) ws = self;
    [[TIMGroupManager sharedInstance] getGroupMembers:_groupId succ:^(NSArray *members) {
        NSMutableArray *allUsers = [NSMutableArray array];
        for (TIMGroupMemberInfo *member in members) {
            TAddCellData *user = [[TAddCellData alloc] init];
            user = [[TAddCellData alloc] init];
            user.identifier = member.member;
            user.head = TUIKitResource(@"default_head");
            user.state = TAddCell_State_UnSelect;
            user.name = member.member;
            [allUsers addObject:user];
        }
        
        ws.selectedData = [NSMutableArray array];
        ws.formatData = [NSMutableArray array];
        ws.formatData = [TAddHelper arrayWithFirstLetterFormat:allUsers];
        [ws.tableView reloadData];
    } fail:^(int code, NSString *msg) {
        
    }];
}

- (void)leftBarButtonClick:(UIButton *)sender
{
    [_textField resignFirstResponder];
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelInDeleteMemberController:)]){
        [_delegate didCancelInDeleteMemberController:self];
    }
}


- (void)rightBarButtonClick:(UIButton *)sender
{
    if(_selectedData.count == 0){
        return;
    }
    [_textField resignFirstResponder];
    
    NSMutableArray *members = [NSMutableArray array];
    for (TAddCellData *item in _selectedData) {
        [members addObject:item.identifier];
    }
    
    __weak typeof(self) ws = self;
    [[TIMGroupManager sharedInstance] deleteGroupMemberWithReason:_groupId reason:@"" members:members succ:^(NSArray *members) {
        if(ws.delegate && [ws.delegate respondsToSelector:@selector(deleteMemberController:didDeleteMemberResult:)]){
            NSMutableArray *deleteArray = [NSMutableArray array];
            for (TIMGroupMemberResult *member in members) {
                [deleteArray addObject:member.member];
            }
            
            TDeleteMemberResult *result = [[TDeleteMemberResult alloc] init];
            result.groupId = ws.groupId;
            result.code = 0;
            result.desc = 0;
            result.delMembers = deleteArray;
            [ws.delegate deleteMemberController:ws didDeleteMemberResult:result];
        }
    } fail:^(int code, NSString *msg) {
        if(ws.delegate && [ws.delegate respondsToSelector:@selector(deleteMemberController:didDeleteMemberResult:)]){
            TDeleteMemberResult *result = [[TDeleteMemberResult alloc] init];
            result.groupId = ws.groupId;
            result.code = code;
            result.desc = msg;
            result.delMembers = nil;
            [ws.delegate deleteMemberController:ws didDeleteMemberResult:result];
        }
    }];
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
    [_selectedData removeAllObjects];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    for (NSInteger s = 0; s < _formatData.count; ++s) {
        NSDictionary *dict = _formatData[s];
        NSMutableArray *array = dict[TLetter_Value];
        for (NSInteger i = 0; i < array.count; ++i) {
            TAddCellData *item = array[i];
            if(s == indexPath.section && i == indexPath.row){
                if(item.state == TAddCell_State_Selected){
                    item.state = TAddCell_State_UnSelect;
                }
                else if(item.state == TAddCell_State_UnSelect){
                    item.state = TAddCell_State_Selected;
                }
            }
            if(item.state == TAddCell_State_Selected){
                [_selectedData addObject:item];
            }
        }
    }
    if(_selectedData.count == 0){
        [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
        _rightButton.enabled = NO;
    }
    else{
        [_rightButton setTitle:[NSString stringWithFormat:@"确定(%ld)",_selectedData.count] forState:UIControlStateNormal];
        _rightButton.enabled = YES;;
    }
    
    [_tableView reloadData];
    [_collectionView reloadData];
    
    CGFloat width = _selectedData.count * [TAddCollectionCell getSize].width;
    if(_selectedData.count > 0){
        width += (_selectedData.count - 1) * _flowLayout.minimumLineSpacing + _flowLayout.headerReferenceSize.width;
    }
    if(width > Screen_Width * 0.6){
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedData.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
    else{
        __weak typeof(self) ws = self;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect collectionFrame = ws.collectionView.frame;
            collectionFrame.size.width = width;
            ws.collectionView.frame = collectionFrame;
            
            CGFloat originX = ws.collectionView.frame.origin.x + ws.collectionView.frame.size.width + TDeleteMemberController_Margin;
            CGRect textFrame = ws.textField.frame;
            textFrame.origin.x = originX;
            textFrame.size.width = ws.view.frame.size.width - originX;
            ws.textField.frame = textFrame;
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_indexView scrollViewDidScroll:scrollView];
}

#pragma mark - collection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _selectedData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TAddCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TAddCollectionCell_ReuseId forIndexPath:indexPath];
    TAddCellData *data = _selectedData[indexPath.row];
    [cell setImage:data.head];
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [TAddCollectionCell getSize];
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
