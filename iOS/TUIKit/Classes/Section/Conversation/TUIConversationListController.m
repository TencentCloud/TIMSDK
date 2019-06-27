//
//  TUIConversationListController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import "TUIConversationListController.h"
#import "TUIConversationCell.h"
#import "TPopView.h"
#import "TPopCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "TUILocalStorage.h"
#import "TIMUserProfile+DataProvider.h"
#import "ReactiveObjC/ReactiveObjC.h"
@import ImSDK;

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface TUIConversationListController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate>
@end

@implementation TUIConversationListController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];


    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = TConversationController_Background_Color;
    [_tableView registerClass:[TUIConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    @weakify(self)
    [RACObserve(self.viewModel, dataList) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.tableView reloadData];
    }];
}



- (TConversationListViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [TConversationListViewModel new];
        _viewModel.listFilter = ^BOOL(TUIConversationCellData * _Nonnull data) {
            return (data.convType != TIM_SYSTEM);
        };
    }
    return _viewModel;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel.dataList[indexPath.row] heightOfWidth:Screen_Width];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        TUIConversationCellData *conv = self.viewModel.dataList[indexPath.row];
        [self.viewModel removeData:conv];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (void)didSelectConversation:(TUIConversationCell *)cell
{
    if(_delegate && [_delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]){
        [_delegate conversationListController:self didSelectConversation:cell];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = [self.viewModel.dataList objectAtIndex:indexPath.row];
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];
    return cell;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
