//
//  TAddGroupController.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TAddGroupController.h"
#import "TAddCell.h"
#import "TAddHeaderView.h"
#import "THeader.h"
#import "TAddHelper.h"
#import "TAddCollectionCell.h"
#import "TPickView.h"
@import ImSDK;


@interface TAddGroupController () <UITableViewDelegate, UITableViewDataSource, TAddIndexViewDelegate, TAddIndexViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, TAddGroupOptionViewDelegate, TPickViewDelegate>
@property (nonatomic, strong) NSMutableArray *formatData;
@property (nonatomic, strong) NSMutableArray *selectedData;
@property (nonatomic, strong) TAddGroupOptionViewData *selectedType;
@property (nonatomic, strong) NSMutableArray *typeData;
@property (nonatomic, strong) TAddGroupOptionViewData *selectedAddOption;
@property (nonatomic, strong) NSMutableArray *addOptionData;
@property (nonatomic, strong) UIButton *rightButton;
@end

@implementation TAddGroupController
{
    UIView *_line3;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self setupViews];
}


- (void)setupViews
{
    if (_addGroupType == AddGroupType_Create) {
        self.title = @"发起群聊";
        self.parentViewController.title = @"发起群聊";
    }else{
        self.title = @"加入群聊";
        self.parentViewController.title = @"加入群聊";
    }
    self.view.backgroundColor = TAddGroupController_Background_Color;
    
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
    //_rightButton.enabled = NO;
    
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
    
    CGFloat textOriginX = _collectionView.frame.origin.x + _collectionView.frame.size.width + TAddGroupController_Margin;
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(textOriginX, StatusBar_Height + NavBar_Height, self.view.frame.size.width - textOriginX, 60)];
    _textField.placeholder = @"输入用户ID";
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_textField];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, _textField.frame.origin.y + _textField.frame.size.height, self.view.frame.size.width, TAddGroupController_Line_Height)];
    line.backgroundColor = TAddGroupController_Line_Color;
    [self.view addSubview:line];
    
    if (_addGroupType == AddGroupType_Create) {
        _groupTypeView = [[TAddGroupOptionView alloc] initWithFrame:CGRectMake(0, line.frame.origin.y + line.frame.size.height, self.view.frame.size.width, TAddGroupOptionView_Height)];
        _groupTypeView.delegate = self;
        [self.view addSubview:_groupTypeView];
        [_groupTypeView setData:_selectedType];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, _groupTypeView.frame.origin.y + _groupTypeView.frame.size.height, self.view.frame.size.width, TAddGroupController_Line_Height)];
        line2.backgroundColor = TAddGroupController_Line_Color;
        [self.view addSubview:line2];
        
        _groupAddOptionView = [[TAddGroupOptionView alloc] initWithFrame:CGRectMake(0, line2.frame.origin.y + line2.frame.size.height, self.view.frame.size.width, TAddGroupOptionView_Height)];
        _groupAddOptionView.delegate = self;
        _groupAddOptionView.hidden = YES;
        [self.view addSubview:_groupAddOptionView];
        [_groupAddOptionView setData:_selectedAddOption];
        
        _line3 = [[UIView alloc] initWithFrame:CGRectMake(0, _groupAddOptionView.frame.origin.y + _groupAddOptionView.frame.size.height, self.view.frame.size.width, TAddGroupController_Line_Height)];
        _line3.backgroundColor = TAddGroupController_Line_Color;
        _line3.hidden = YES;
        [self.view addSubview:_line3];
        
        CGFloat originY = _line3.frame.origin.y + _line3.frame.size.height;
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
    }else{
        _textField.placeholder = @"输入群组ID";
    }
}

- (void)setupData
{
    
    _addOptionData = [NSMutableArray array];
    TAddGroupOptionData *forbid = [[TAddGroupOptionData alloc] init];
    forbid.title = @"禁止加入";
    forbid.value = [NSNumber numberWithInt:0];
    TAddGroupOptionData *auth = [[TAddGroupOptionData alloc] init];
    auth.title = @"管理员审批";
    auth.value = [NSNumber numberWithInt:1];
    TAddGroupOptionData *any = [[TAddGroupOptionData alloc] init];
    any.title = @"自动审批";
    any.value = [NSNumber numberWithInt:2];
    [_addOptionData addObject:forbid];
    [_addOptionData addObject:auth];
    [_addOptionData addObject:any];
    
    
    _typeData = [NSMutableArray array];
    TAddGroupOptionData *private = [[TAddGroupOptionData alloc] init];
    private.title = @"私有群";
    private.value = @"Private";
    TAddGroupOptionData *public = [[TAddGroupOptionData alloc] init];
    public.title = @"公开群";
    public.value = @"Public";
    TAddGroupOptionData *chatRoom = [[TAddGroupOptionData alloc] init];
    chatRoom.title = @"聊天室";
    chatRoom.value = @"ChatRoom";
    [_typeData addObject:private];
    [_typeData addObject:public];
    [_typeData addObject:chatRoom];
    
    
    _selectedAddOption = [[TAddGroupOptionViewData alloc] init];
    _selectedAddOption.title = @"加群权限";
    _selectedAddOption.value = forbid;
    
    _selectedType = [[TAddGroupOptionViewData alloc] init];
    _selectedType.title = @"群组类型";
    _selectedType.value = private;
    
    _selectedData = [NSMutableArray array];
    _formatData = [NSMutableArray array];
    _formatData = [TAddHelper arrayWithFirstLetterFormat:_data];
}

- (void)leftBarButtonClick:(UIButton *)sender
{
    [_textField resignFirstResponder];
    if(_delegate && [_delegate respondsToSelector:@selector(didCancelInAddGroupController:)]){
        [_delegate didCancelInAddGroupController:self];
    }
}


- (void)rightBarButtonClick:(UIButton *)sender
{
//    if(_selectedData.count == 0){
//        return;
//    }
    if(_textField.text.length == 0){
        return;
    }
    [_textField resignFirstResponder];
    
    if (_addGroupType == AddGroupType_Create) {
        NSString *groupType = (NSString *)_selectedType.value.value;
        NSNumber *addOption = (NSNumber *)_selectedAddOption.value.value;
        NSString *groupName = [[TIMManager sharedInstance] getLoginUser];
        
        if ([groupName isEqualToString:_textField.text]) {
             __weak typeof(self) ws = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ws.delegate && [ws.delegate respondsToSelector:@selector(addGroupController:didJoinGroupIdFailed:errorMsg:)]) {
                    [ws.delegate addGroupController:ws didCreateGroupIdFailed:-1 errorMsg:@"创建群聊失败，不能和自己发起群聊"];
                }
            });
            return;
        }
        
        NSMutableArray *members = [NSMutableArray array];
        //    for (TAddCellData *item in _selectedData) {
        //        NSString *tmp = [NSString stringWithFormat:@"%@、%@", groupName, item.name];
        //        if([self getByteLength:tmp] > 20){
        //            break;
        //        }
        //        groupName = tmp;
        //    }
        
        groupName = [NSString stringWithFormat:@"%@、%@", groupName, _textField.text];
        
        
        //    for (TAddCellData *item in _selectedData) {
        //        TIMCreateGroupMemberInfo *member = [[TIMCreateGroupMemberInfo alloc] init];
        //        member.member = item.identifier;
        //        member.role = TIM_GROUP_MEMBER_ROLE_MEMBER;
        //        [members addObject:member];
        //    }
        TIMCreateGroupMemberInfo *member = [[TIMCreateGroupMemberInfo alloc] init];
        member.member = _textField.text;
        member.role = TIM_GROUP_MEMBER_ROLE_MEMBER;
        [members addObject:member];
        
        TIMCreateGroupInfo *info = [[TIMCreateGroupInfo alloc] init];
        info.groupName = groupName;
        info.groupType = groupType;
        if([info.groupType isEqualToString:@"Private"]){
            info.setAddOpt = false;
        }
        else{
            info.setAddOpt = true;
            info.addOpt = (TIMGroupAddOpt)addOption.intValue;
        }
        info.membersInfo = members;
        
        __weak typeof(self) ws = self;
        [[TIMGroupManager sharedInstance] createGroup:info succ:^(NSString *groupId) {
            TIMMessage *tip = [[TIMMessage alloc] init];
            TIMCustomElem *custom = [[TIMCustomElem alloc] init];
            custom.data = [@"group_create" dataUsingEncoding:NSUTF8StringEncoding];
            custom.ext = [NSString stringWithFormat:@"\"%@\"创建群组", [[TIMManager sharedInstance] getLoginUser]];
            [tip addElem:custom];
            TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:groupId];
            [conv sendMessage:tip succ:nil fail:nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(addGroupController:didCreateGroupId:groupName:)]){
                    [ws.delegate addGroupController:ws didCreateGroupId:groupId groupName:groupName];
                }
            });
        } fail:^(int code, NSString *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ws.delegate && [ws.delegate respondsToSelector:@selector(addGroupController:didJoinGroupIdFailed:errorMsg:)]) {
                    [ws.delegate addGroupController:ws didCreateGroupIdFailed:code errorMsg:msg];
                }
            });
        }];
    }else{
        __weak typeof(self) ws = self;
        [[TIMGroupManager sharedInstance] joinGroup:_textField.text msg:[NSString stringWithFormat:@"%@ 申请加入群聊",[[TIMManager sharedInstance] getLoginUser]] succ:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.delegate && [ws.delegate respondsToSelector:@selector(addGroupController:didJoinGroupId:)]){
                    [ws.delegate addGroupController:ws didJoinGroupId:ws.textField.text];
                }
            });
        } fail:^(int code, NSString *msg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (ws.delegate && [ws.delegate respondsToSelector:@selector(addGroupController:didJoinGroupIdFailed:errorMsg:)]) {
                    [ws.delegate addGroupController:ws didJoinGroupIdFailed:code errorMsg:msg];
                }
            });
        }];
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
            
            CGFloat originX = ws.collectionView.frame.origin.x + ws.collectionView.frame.size.width + TAddGroupController_Margin;
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

#pragma mark - add group option
- (void)didTapInAddGroupOptionView:(TAddGroupOptionView *)view
{
    NSMutableArray *array = [NSMutableArray array];
    TPickView *pick = [[TPickView alloc] init];
    pick.delegate = self;
    if(view == _groupTypeView){
        pick.tag = 0;
        for (TAddGroupOptionData *item in _typeData) {
            [array addObject:item.title];
        }
    }
    else if(view == _groupAddOptionView){
        pick.tag = 1;
        for (TAddGroupOptionData *item in _addOptionData) {
            [array addObject:item.title];
        }
    }
    [pick setData:array];
    [pick showInWindow:self.view.window];
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



#pragma makr - pick view
- (void)pickView:(TPickView *)pickView didSelectRowAtIndex:(NSInteger)index
{
    if(pickView.tag == 0){
        TAddGroupOptionData *data = _typeData[index];
        _selectedType.value = data;
        [_groupTypeView setData:_selectedType];
        
        //私有群禁止加入
        if (index == 0) {
            TAddGroupOptionData *data = _addOptionData[0];
            _selectedAddOption.value = data;
            [_groupAddOptionView setData:_selectedAddOption];
            [_groupAddOptionView setHidden:YES];
            [_line3 setHidden:YES];
        }else{
            [_groupAddOptionView setHidden:NO];
            [_line3 setHidden:NO];
        }
    }
    else if(pickView.tag == 1){
        TAddGroupOptionData *data = _addOptionData[index];
        _selectedAddOption.value = data;
        [_groupAddOptionView setData:_selectedAddOption];
    }
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

- (NSInteger)getByteLength:(NSString *)string
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [string dataUsingEncoding:enc];
    return [da length];
}

@end
