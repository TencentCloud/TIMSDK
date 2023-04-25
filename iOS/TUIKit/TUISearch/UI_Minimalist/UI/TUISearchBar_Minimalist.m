//
//  TUISearchBar_Minimalist.m
//  Pods
//
//  Created by harvy on 2020/12/23.
//

#import "TUISearchBar_Minimalist.h"
#import "TUISearchViewController_Minimalist.h"
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/UIView+TUILayout.h>
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@interface TUISearchBar_Minimalist () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL isEntrance;
@end

@implementation TUISearchBar_Minimalist
@synthesize delegate;

- (void)setEntrance:(BOOL)isEntrance {
    self.isEntrance = isEntrance;
    [self setupViews];
}

- (UIColor *)bgColorOfSearchBar
{
    return RGBA(255, 255, 255, 1);
}

- (void)setupViews
{
    
    self.backgroundColor = self.bgColorOfSearchBar;
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = TIMCommonLocalizableString(Search);
    _searchBar.backgroundImage = [UIImage new];
    _searchBar.barTintColor = UIColor.redColor;
    _searchBar.showsCancelButton = NO;
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = !self.isEntrance;
    if (@available(iOS 13.0, *)) {
        _searchBar.searchTextField.backgroundColor = RGBA(246, 246, 246, 1);
    }
    [self addSubview:_searchBar];
    [self enableCancelButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.searchBar.frame = CGRectMake(10, 5, self.mm_w - 10 - 10, self.mm_h - 5 - 5);
    
    [self updateSearchIcon];
}

- (void)updateSearchIcon
{
    if ([self.searchBar isFirstResponder] || self.searchBar.text.length || !self.isEntrance) {
        self.backgroundColor = self.superview.backgroundColor;
    } else {
        self.backgroundColor = self.bgColorOfSearchBar;
    }
    [self.searchBar setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
}

- (void)showSearchVC {
    TUISearchViewController_Minimalist *vc = [[TUISearchViewController_Minimalist alloc] init];
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
        
        [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]].title = TIMCommonLocalizableString(TUIKitSearchItemCancel);;
    });
}


@end
