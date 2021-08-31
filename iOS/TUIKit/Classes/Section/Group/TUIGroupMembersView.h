/******************************************************************************
 *
 *  本文件声明了 TGroupMembersViewDelegate 协议和 TUIGroupMembersView 类。
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "TUIGroupMemberCell.h"

@class TUIGroupMembersView;

/////////////////////////////////////////////////////////////////////////////////
//
//                     TGroupMembersViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////
@protocol TGroupMembersViewDelegate <NSObject>

/**
 *  在群成员视图中点击某一具体成员单元的回调。
 *  您可以通过该回调实现：点击某一成员头像后，跳转到对应成员的群名片/详细信息界面。
 *
 *  @param groupMembersView 委托者，当前群成员视图。
 *  @param groupMember 选择的成员的对应群成员信息源，包含对应群成员的 ID、头像、群昵称等。
 */
- (void)groupMembersView:(TUIGroupMembersView *)groupMembersView didSelectGroupMember:(TGroupMemberCellData *)groupMember;

/**
 *  加载更多数据
 *
 *  @param groupMembersView 委托者，当前群成员视图。
 *  @param completion 完成加载后的数据回调
 */
- (void)groupMembersView:(TUIGroupMembersView *)groupMembersView didLoadMoreData:(void(^)(NSArray<TGroupMemberCellData *> *))completion;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                       TUIGroupMembersView
//
/// //////////////////////////////////////////////////////////////////////////////
@interface TUIGroupMembersView : UIView

/**
 *  搜索栏，能够在当前视图快捷搜索到对应的群成员。
 */
@property (nonatomic, strong) UISearchBar *searchBar;

/**
 *  群成员视图的 collectionView。统一存放 TGroupMemberCell。
 *  以多行多列的形式存放 TGroupMemberCell，并配合 flowLayout 进行灵活统一的视图布局。
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 *  collectionView 的流水布局
 *  配合 collectionView，用来维护群成员视图的布局，使群成员单元更加美观。能够设置布局方向、行间距、cell 间距等。
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

/**
 *  委托类，负责实现 TGroupMembersViewDelegate 委托。
 */
@property (nonatomic, weak) id<TGroupMembersViewDelegate> delegate;

/**
 * 上拉加载更多的指示器
 */
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

/**
 *  设置数据。根据传入的数据对当前视图进行设置。
 *
 *  @param data 传入的数据，内含各个群成员的单元数据源（TGroupMemberCellData）。
 */
- (void)setData:(NSMutableArray<TGroupMemberCellData *> *)data;
@end
