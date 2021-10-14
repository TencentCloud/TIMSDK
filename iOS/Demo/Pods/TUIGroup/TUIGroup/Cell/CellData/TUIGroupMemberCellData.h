//
//  TUIGroupMemberCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//

#import <Foundation/Foundation.h>
@import UIKit;
NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                         TUIGroupMemberCellData
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIGroupMemberCellData
 * 【功能说明】群成员单元数据源，负责存放群成员单元的一系列所需信息与数据。
 *  存放数据包括群成员头像、ID、群名称以及成员标签。
 */
@interface TUIGroupMemberCellData : NSObject

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
 *  群成员头像
 */
@property (nonatomic, strong) UIImage *avatarImage;

/**
 *  群成员头像 url
 */
@property (nonatomic, strong) NSString *avatarUrl;

/**
 *  成员标签，作为不同状态的标识符。
 *  tag = 1，该成员可以添加，待添加进群。可以理解为未进群且为邀请者联系人的用户 tag 赋值为1。
 *  tag = 2，该成员可以删除，待删除出群。可以理解为已进群且可以踢出的用户（非群主、管理）tag 赋值为2。
 */
@property NSInteger tag;
@end
NS_ASSUME_NONNULL_END
