//
//  TUISearchFriendViewController.m
//  TIMChat
//
//  Created by AlexiChen on 16/2/29.
//  Copyright © 2016 AlexiChen. All rights reserved.
//
#import "TUISearchFriendViewController_Minimalist.h"
#import <TUICore/TUIThemeManager.h>
#import "TUIDefine.h"
#import "TUIFriendRequestViewController_Minimalist.h"

@interface AddFriendUserView_Minimalist : UIView
@property(nonatomic) V2TIMUserFullInfo *profile;
@end

@implementation AddFriendUserView_Minimalist {
    UILabel *_idLabel;
    UIView *_line;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    _idLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:_idLabel];

    _line = [[UIView alloc] initWithFrame:CGRectZero];
    _line.backgroundColor = [UIColor grayColor];
    [self addSubview:_line];

    return self;
}

- (void)setProfile:(V2TIMUserFullInfo *)profile {
    _profile = profile;
    if (_profile) {
        _idLabel.text = profile.userID;
        _idLabel.mm_sizeToFit().tui_mm_center().mm_left(8);
        _line.mm_height(1).mm_width(self.mm_w).mm_bottom(0);
        _line.hidden = NO;
    } else {
        _idLabel.text = @"";
        _line.hidden = YES;
    }
}

@end

@interface TUISearchFriendViewController_Minimalist () <UISearchResultsUpdating>

@property(nonatomic, strong) AddFriendUserView_Minimalist *userView;
;

@end

@interface TUISearchFriendViewController_Minimalist () <UISearchControllerDelegate, UISearchResultsUpdating, UISearchResultsUpdating>

@end

@implementation TUISearchFriendViewController_Minimalist

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = TIMCommonLocalizableString(ContactsAddFriends);

    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.definesPresentationContext = YES;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    _searchController.searchBar.placeholder = TIMCommonLocalizableString(SearchGroupPlaceholder);
    [self.view addSubview:_searchController.searchBar];
    self.searchController.searchBar.mm_sizeToFit();
    [self setSearchIconCenter:YES];

    self.userView = [[AddFriendUserView_Minimalist alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.userView];

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserTap:)];
    [self.userView addGestureRecognizer:singleFingerTap];
}

- (void)setSearchIconCenter:(BOOL)center {
    if (center) {
        CGSize size = [self.searchController.searchBar.placeholder sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]}];
        CGFloat width = size.width + 60;
        [self.searchController.searchBar setPositionAdjustment:UIOffsetMake(0.5 * (self.searchController.searchBar.bounds.size.width - width), 0)
                                              forSearchBarIcon:UISearchBarIconSearch];
    } else {
        [self.searchController.searchBar setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    [self setSearchIconCenter:NO];
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"didPresentSearchController");
    [self.view addSubview:self.searchController.searchBar];

    self.searchController.searchBar.mm_top([self safeAreaTopGap]);
    self.userView.mm_top(self.searchController.searchBar.mm_maxY).mm_height(44).mm_width(Screen_Width);
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    [self setSearchIconCenter:YES];
}

- (CGFloat)safeAreaTopGap {
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

- (void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"didDismissSearchController");
    self.searchController.searchBar.mm_top(0);
    self.userView.profile = nil;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *inputStr = searchController.searchBar.text;
    NSLog(@"serach %@", inputStr);
    [[V2TIMManager sharedInstance] getUsersInfo:@[ inputStr ]
        succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
          self.userView.profile = infoList.firstObject;
        }
        fail:^(int code, NSString *msg) {
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

- (void)handleUserTap:(id)sender {
    if (self.userView.profile.userID.length > 0) {
        TUIFriendRequestViewController_Minimalist *frc = [[TUIFriendRequestViewController_Minimalist alloc] init];
        frc.profile = self.userView.profile;
        [self.navigationController pushViewController:frc animated:YES];
    }
}
@end
