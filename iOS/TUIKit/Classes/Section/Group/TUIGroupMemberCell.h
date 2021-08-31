/******************************************************************************
 *
 *  本文件声明了 TGroupMemberCellData 类和 TUIGroupMemberCell 类。
 *  群成员单元，即在群组信息中的群成员模块中，代表单个群成员的 UI 单元。包含群成员的头像与群昵称。
 *  TGroupMemberCellData 内存放了对应群成员的 ID、头像以及群昵称。
 *  TUIGroupMemberCell 则作为 UI 的显示单元，从 TGroupMemberCellData 中获取单元并显示，同时响应用户的点击操作。
 *
 ******************************************************************************/
#import <UIKit/UIKit.h>


/////////////////////////////////////////////////////////////////////////////////
//
//                         TGroupMemberCellData
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TGroupMemberCellData
 * 【功能说明】群成员单元数据源，负责存放群成员单元的一系列所需信息与数据。
 *  存放数据包括群成员头像、ID、群名称以及成员标签。
 */
@interface TGroupMemberCellData : NSObject

/**
 *  群成员 ID
 */
@property (nonatomic, strong) NSString *identifier;
/**
 *  成员的群昵称。
 *  此处有别与成员 ID，成员 ID 为成员的唯一标识符，而同一个用户可以在不同的群中使用不同的群昵称。
 */
@property (nonatomic, strong) NSString *name;
/**
 *  群成员头像及url
 */
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSString *avatarUrl;

/**
 *  成员标签，作为不同状态的标识符。
 *  tag = 1，该成员可以添加，待添加进群。可以理解为未进群且为邀请者联系人的用户 tag 赋值为1。
 *  tag = 2，该成员可以删除，待删除出群。可以理解为已进群且可以踢出的用户（非群主、管理）tag 赋值为2。
 */
@property NSInteger tag;
@end


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
@property (nonatomic, strong) TGroupMemberCellData *data;

@end
