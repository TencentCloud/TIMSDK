//
//  SearchGroupViewController.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/5/20.
//  Copyright © 2019年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo查找群组视图
 *  本文件实现了查找群组的视图控制器，使用户能够根据群组ID查找指定群组
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import "SearchGroupViewController.h"
#import "UIView+MMLayout.h"
#import "TIMFriendshipManager.h"
#import "FriendRequestViewController.h"
#import "GroupRequestViewController.h"
#import "THeader.h"

// MLeaksFinder 会对这个类误报，这里需要关闭一下
@implementation UISearchController (Leak)

- (BOOL)willDealloc {
    return NO;
}

@end

@interface AddGroupItemView : UIView
@property (nonatomic) TIMGroupInfo *groupInfo;
@end

@implementation AddGroupItemView
{
    UILabel *_idLabel;
    UIView  *_line;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    _idLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_idLabel];

    _line = [[UIView alloc] initWithFrame:CGRectZero];
    _line.backgroundColor = [UIColor grayColor];
    [self addSubview:_line];


    return self;
}

/**
 *群组信息设置
 */
- (void)setGroupInfo:(TIMGroupInfo *)groupInfo
{
    if (groupInfo) {
        if (groupInfo.groupName.length > 0) {
            _idLabel.text = [NSString stringWithFormat:@"%@ (group id: %@)",groupInfo.groupName,groupInfo.group];
        } else {
            _idLabel.text = groupInfo.group;
        }
        _idLabel.mm_sizeToFit().mm_center().mm_left(8);
        _line.mm_height(1).mm_width(self.mm_w).mm_bottom(0);
        _line.hidden = NO;
    } else {
        _idLabel.text = @"";
        _line.hidden = YES;
    }


    _groupInfo = groupInfo;
}

@end

@interface SearchGroupViewController()<UISearchResultsUpdating>

@property (nonatomic,strong) AddGroupItemView *userView;;

@end



@interface SearchGroupViewController() <UISearchControllerDelegate,UISearchResultsUpdating,UISearchResultsUpdating>

@end

@implementation SearchGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"添加群组";

    self.view.backgroundColor = TSettingController_Background_Color;

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;//不设置会导致一些位置错乱，无动画等问题

    // 创建搜索框
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    //设置代理
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.placeholder = @"群组ID";
    [self.view addSubview:_searchController.searchBar];

    self.userView = [[AddGroupItemView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.userView];

    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleUserTap:)];
    [self.userView addGestureRecognizer:singleFingerTap];
}

#pragma mark - UISearchControllerDelegate
/**
 * searchController委托函数
 */
- (void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"didPresentSearchController");
    [self.view addSubview:self.searchController.searchBar];

    self.searchController.searchBar.mm_top([self safeAreaTopGap]);
    self.userView.mm_top(self.searchController.searchBar.mm_maxY).mm_height(44).mm_width(Screen_Width);
}

- (CGFloat)safeAreaTopGap
{
    NSNumber *gap;
    if (gap == nil) {
        if (@available(iOS 11, *)) {
            gap = @(self.view.safeAreaLayoutGuide.layoutFrame.origin.y);
        } else {
            gap = @(0);
        }
    }
    return gap.floatValue;
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"didDismissSearchController");
    self.searchController.searchBar.mm_top(0);
    self.userView.groupInfo = nil;
}

/**
 *searchController中的内容每次更新，都会调用改函数进行一次当前内容的搜索
 */
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text ;
    NSLog(@"serach %@", inputStr);

    [[TIMGroupManager sharedInstance] getGroupInfo:@[inputStr] succ:^(NSArray *arr) {
        if(arr.count >= 1) {
            self.userView.groupInfo = arr[0];
        } else {
            self.userView.groupInfo = nil;
        }
    } fail:^(int code, NSString *msg) {
        self.userView.groupInfo = nil;
    }];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.searchController.active = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchController.active = NO;
}

- (void)handleUserTap:(id)sender
{
    if (self.userView.groupInfo)
    {
        GroupRequestViewController *frc = [[GroupRequestViewController alloc] init];
        frc.groupInfo = self.userView.groupInfo;
        [self.navigationController pushViewController:frc animated:YES];
    }
}
@end
