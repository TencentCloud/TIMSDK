/******************************************************************************
 *
 *  本文件声明了用于展现群成员信息的模块与组件。
 *  在群信息界面，采用了 TableView 进行群组详细信息的展示。而“群成员”则是其中的一个 TableViewCell。
 *  本文件则负责实现在一个 TableCell 中显示若干群成员单元。
 *
 *  TGroupMembersCellDelegate 协议实现了具体某一 membersCell 的点击响应回调。
 *  TGroupMembersCellData 类存放了群成员的群组，即在群组“详细资料”界面中要显示的群成员。当前默认显示群组内的前10个成员。
 *  TUIGroupMembersCell 在“详细信息”的 TableView 中进行显示的 TableViewCell。
 *
 ******************************************************************************/


#import <UIKit/UIKit.h>

@class TUIGroupMembersCell;

/////////////////////////////////////////////////////////////////////////////////
//
//                        TGroupMembersCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////


@protocol TGroupMembersCellDelegate <NSObject>

/**
 *  点击“群成员”中具体某一群成员的回调委托。
 *  “群成员”模块为群组“详细信息”界面中的一个 TableViewCell。
 *  同时，“群成员“自身也包含很多 Cell。
 *  此处的回调委托便是”群成员“内部的 Cell 被点击时的回调委托。
 *
 *  @param cell 委托者，当前的“群成员”模块的 TableCell。
 *  @param index “群成员”模块中被点击的 Cell 的下标。
 */
- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        TGroupMembersCellData
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TGroupMembersCellData
 * 【功能说明】“群成员”模块数据源，负责存放“群成员”模块所需的数据。
 *  目前本类主要负责存放“群成员”模块内所展示的群成员的信息。即 members 数组中存放的对象为 TGroupMemberCellData。
 */
@interface TGroupMembersCellData : NSObject
@property (nonatomic, strong) NSMutableArray *members;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        TUIGroupMembersCell
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIGroupMembersCell
 * 【功能说明】“群成员”模块，用于在群组的“详细信息”中展示群内的部分群成员（默认展示前10个）。
 *  本类同时是“群成员”界面的响应入口，点击本 Cell 可以跳转到“群成员”界面，通过“群成员”界面可以浏览群内的全部群成员。
 */
@interface TUIGroupMembersCell : UITableViewCell

/**
 *  群成员模块的 CollectionView
 *  包含多个 TGroupMemberCell，默认情况下显示2行5列共10个群成员，并配合 memberFlowLayout 进行灵活统一的视图布局。
 */
@property (nonatomic, strong) UICollectionView *memberCollectionView;

/**
 *  memberCollectionView 的流水布局
 *  配合 memberCollectionView，用来维护“群成员”模块内的的布局，使成员的头像单元排布更加美观。能够设置布局方向、行间距、cell 间距等。
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *memberFlowLayout;

/**
 *  委托类，负责实现 TGroupMembersCellDelegate 协议中的委托。
 */
@property (nonatomic, weak) id<TGroupMembersCellDelegate> delegate;

/**
 *  群成员数据源，本类从 data 中获取需要显示的成员信息，并在“群成员”模块中显示。
 */
@property (nonatomic) TGroupMembersCellData *data;

/**
 *  目前“群成员“模块默认显示2行5列共10个群成员头像单元。
 *  当要显示的群成员小于列数（当前为5）时，返回 1 行的高度。
 *  当要显示的群成员大于行数（当前为2）时，返回最大行数（2行）对应的高度。
 *
 *  @retrun 高度，通过 行数*每行高度 计算得来。
 */
+ (CGFloat)getHeight:(TGroupMembersCellData *)data;

@end
