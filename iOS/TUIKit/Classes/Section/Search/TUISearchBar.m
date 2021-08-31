//
//  TUISearchBar.m
//  Pods
//
//  Created by harvy on 2020/12/23.
//

#import "TUISearchBar.h"
#import "NSBundle+TUIKIT.h"
#import "UIColor+TUIDarkMode.h"
#import <MMLayout/UIView+MMLayout.h>

@interface TUISearchBar () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL isEntrance;
@end

@implementation TUISearchBar

- (instancetype)initWithEntrance:(BOOL)isEntrance
{
    if (self = [super init]) {
        self.isEntrance = isEntrance;
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.placeholder = TUILocalizableString(Search); // @"搜索";
    _searchBar.backgroundImage = [UIImage new];
    _searchBar.barTintColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:1.0]];
    _searchBar.showsCancelButton = NO;
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = !self.isEntrance;
    if (@available(iOS 13.0, *)) {
        _searchBar.searchTextField.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:1.0]];
    }
    [self addSubview:_searchBar];
    [self enableCancelButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.searchBar.frame = CGRectMake(10, 5, self.mm_w - 10 - 10, self.mm_h - 5 - 5);
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    } else {
        [self.searchBar setPositionAdjustment:UIOffsetMake(0.5 * (self.mm_w - 10 - 10) - 40, 0) forSearchBarIcon:UISearchBarIconSearch];
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (self.isEntrance && [self.delegate respondsToSelector:@selector(searchBarDidEnterSearch:)]) {
        [self.delegate searchBarDidEnterSearch:self];
    }
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
