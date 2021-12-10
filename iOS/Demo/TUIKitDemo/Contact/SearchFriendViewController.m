//
//  SearchFriendViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
/** 腾讯云IM Demo查找好友视图
 *  本文件实现了查找好友的视图控制器，使用户能够根据用户ID查找指定用户
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import "SearchFriendViewController.h"
#import "FriendRequestViewController.h"
#import "TUIKit.h"

@interface AddFriendUserView : UIView
@property (nonatomic) V2TIMUserFullInfo *profile;
@end

@implementation AddFriendUserView
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
 *设置用户信息
 */
- (void)setProfile:(V2TIMUserFullInfo *)profile
{
    _profile = profile;
    if (_profile) {
        _idLabel.text = profile.userID;
        _idLabel.mm_sizeToFit().mm_center().mm_left(8);
        _line.mm_height(1).mm_width(self.mm_w).mm_bottom(0);
        _line.hidden = NO;
    } else {
        _idLabel.text = @"";
        _line.hidden = YES;
    }
}

@end

@interface SearchFriendViewController()<UISearchResultsUpdating>

@property (nonatomic,strong) AddFriendUserView *userView;;

@end



@interface SearchFriendViewController() <UISearchControllerDelegate,UISearchResultsUpdating,UISearchResultsUpdating>

@end

@implementation SearchFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"ContactsAddFriends", nil); // @"添加好友";

    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;//不设置会导致一些位置错乱，无动画等问题

    // 创建搜索框
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    //设置代理
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.placeholder = NSLocalizedString(@"SearchGroupPlaceholder", nil); // @"用户ID";
    [self.view addSubview:_searchController.searchBar];
    self.searchController.searchBar.mm_sizeToFit();
    [self setSearchIconCenter:YES];

    self.userView = [[AddFriendUserView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.userView];

    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleUserTap:)];
    [self.userView addGestureRecognizer:singleFingerTap];
}

- (void)setSearchIconCenter:(BOOL)center
{
    if (center) {
        CGSize size = [self.searchController.searchBar.placeholder sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
        CGFloat width = size.width + 60;
        [self.searchController.searchBar setPositionAdjustment:UIOffsetMake(0.5  *(self.searchController.searchBar.bounds.size.width - width), 0) forSearchBarIcon:UISearchBarIconSearch];
    } else {
        [self.searchController.searchBar setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController
{
    [self setSearchIconCenter:NO];
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"didPresentSearchController");
    [self.view addSubview:self.searchController.searchBar];

    self.searchController.searchBar.mm_top([self safeAreaTopGap]);
    self.userView.mm_top(self.searchController.searchBar.mm_maxY).mm_height(44).mm_width(Screen_Width);
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    [self setSearchIconCenter:YES];
}

/**
 *设置UI显示的安全区域，防止View被异性屏等遮挡
 */
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
    self.userView.profile = nil;
}

/**
 *searchController中的内容每次更新，都会调用改函数进行一次当前内容的搜索
 */
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text ;
    NSLog(@"serach %@", inputStr);
    [[V2TIMManager sharedInstance] getUsersInfo:@[inputStr] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
        self.userView.profile = infoList.firstObject;
    } fail:^(int code, NSString *msg) {
        self.userView.profile = nil;
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
    if (self.userView.profile.userID.length > 0)
    {
        FriendRequestViewController *frc = [[FriendRequestViewController alloc] init];
        frc.profile = self.userView.profile;
        [self.navigationController pushViewController:frc animated:YES];
    }
}
@end
