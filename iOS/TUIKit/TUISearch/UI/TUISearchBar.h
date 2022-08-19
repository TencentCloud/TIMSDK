//
//  TUISearchBar.h
//  Pods
//
//  Created by harvy on 2020/12/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUISearchBar;
@protocol TUISearchBarDelegate <NSObject>

@optional
- (void)searchBarDidEnterSearch:(TUISearchBar *)searchBar;
- (void)searchBarDidCancelClicked:(TUISearchBar *)searchBar;
- (void)searchBar:(TUISearchBar *)searchBar searchText:(NSString *)key;
@end


@interface TUISearchBar : UIView

@property (nonatomic, strong, readonly) UISearchBar *searchBar;

@property (nonatomic, weak) id<TUISearchBarDelegate> delegate;

@property (nonatomic, strong) UIViewController *parentVC;

- (void)setEntrance:(BOOL)isEntrance;


@end

NS_ASSUME_NONNULL_END
