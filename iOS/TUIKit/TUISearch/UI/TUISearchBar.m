//
//  TUISearchBar.m
//  Pods
//
//  Created by harvy on 2020/12/23.
//

#import "TUISearchBar.h"
#import "TUISearchViewController.h"
#import "TUIGlobalization.h"
#import "TUIDarkModel.h"
#import "UIView+TUILayout.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@interface TUISearchBar () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL isEntrance;
@property (nonatomic, strong) UIView *coverView;
@end

@implementation TUISearchBar
@synthesize delegate;

- (void)setEntrance:(BOOL)isEntrance {
    self.isEntrance = isEntrance;
    [self setupViews];
    self.coverView.hidden = !isEntrance;
}

- (UIColor *)bgColorOfSearchBar
{
    return TUICoreDynamicColor(@"head_bg_gradient_start_color", @"#EBF0F6");
}

- (void)setupViews
{
    
    self.backgroundColor = self.bgColorOfSearchBar;
    _coverView = [[UIView alloc] init];
    _coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    _coverView.hidden = YES;
    [self addSubview:_coverView];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = TUIKitLocalizableString(Search); // @"搜索";
    _searchBar.backgroundImage = [UIImage new];
    _searchBar.barTintColor = UIColor.redColor;
    _searchBar.showsCancelButton = NO;
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = !self.isEntrance;
    if (@available(iOS 13.0, *)) {
        _searchBar.searchTextField.backgroundColor = TUISearchDynamicColor(@"search_textfield_bg_color", @"#FEFEFE");
    }
    [self addSubview:_searchBar];
    [self enableCancelButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.coverView.frame = self.bounds;
    self.searchBar.frame = CGRectMake(10, 5, self.mm_w - 10 - 10, self.mm_h - 5 - 5);
    
    [self updateSearchIcon];
}

- (void)updateSearchIcon
{
    if ([self.searchBar isFirstResponder] || self.searchBar.text.length || !self.isEntrance) {
        [self.searchBar setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
        self.backgroundColor = self.superview.backgroundColor;
    } else {
        [self.searchBar setPositionAdjustment:UIOffsetMake(0.5 * (self.mm_w - 10 - 10) - 40, 0) forSearchBarIcon:UISearchBarIconSearch];
        self.backgroundColor = self.bgColorOfSearchBar;
    }
}

- (void)showSearchVC {
    TUISearchViewController *vc = [[TUISearchViewController alloc] init];
    TUINavigationController *nav = [[TUINavigationController alloc] initWithRootViewController:(UIViewController *)vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.parentVC presentViewController:nav animated:NO completion:nil];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self showSearchVC];
    
    if (self.isEntrance && [self.delegate respondsToSelector:@selector(searchBarDidEnterSearch:)]) {
        [self.delegate searchBarDidEnterSearch:self];
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateSearchIcon];
    });
    return !self.isEntrance;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBarDidCancelClicked:)]) {
        [self.delegate searchBarDidCancelClicked:self];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(searchBar:searchText:)]) {
        [self.delegate searchBar:self searchText:searchBar.text];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.delegate respondsToSelector:@selector(searchBar:searchText:)]) {
        [self.delegate searchBar:self searchText:searchBar.text];
    }
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self enableCancelButton];
}

- (void)enableCancelButton
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIButton *cancelBtn = [weakSelf.searchBar valueForKeyPath:@"cancelButton"];
        for (UIButton *view in cancelBtn.subviews) {
            if ([view isKindOfClass:UIButton.class]) {
                view.userInteractionEnabled = YES;
                view.enabled = YES;
            }
        }
        cancelBtn.enabled = YES;
        cancelBtn.userInteractionEnabled = YES;
    });
}


@end
