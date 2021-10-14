/******************************************************************************
 *
 *  本文件声明了 TUIGroupMemberCellData 类和 TUIGroupMemberCell 类。
 *  群成员单元，即在群组信息中的群成员模块中，代表单个群成员的 UI 单元。包含群成员的头像与群昵称。
 *  TUIGroupMemberCellData 内存放了对应群成员的 ID、头像以及群昵称。
 *  TUIGroupMemberCell 则作为 UI 的显示单元，从 TUIGroupMemberCellData 中获取单元并显示，同时响应用户的点击操作。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>
#import "TUIGroupMemberCellData.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIGroupMemberCell
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TGroupMemberCell
 * 【功能说明】群成员单元，作为在 collectionView 中的显示单元。
 *  负责显示群成员信息，同时作为用户点击操作的响应单元。
 */
@interface TUIGroupMemberCell : UICollectionViewCell

/**
 *  头像视图
 *  用于在单元中显示用户的头像。
 */
@property (nonatomic, strong) UIImageView *head;

/**
 *  群名称
 *  用于在单元中显示用户的群昵称。
 *  此处显示的是用户的群昵称，当用户群昵称为设置时，默认显示用户的 ID。
 */
@property (nonatomic, strong) UILabel *name;
/**
 *  获取当前群成员单元的 UI 面积大小。
 *
 *  @return 成员单元的面积大小，以 CGSize 的格式返回。
 */
+ (CGSize)getSize;

/**
 *  设置数据
 *  根据传入的 data 设置单元的头像和群昵称标签。
 *  本函数同时会执行一次布局设置，设置好单元的大小、边距等布局信息。
 */
@property (nonatomic, strong) TUIGroupMemberCellData *data;
@end
