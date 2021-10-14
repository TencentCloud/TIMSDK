//
//  TUIGroupMembersCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                        TUIGroupMembersCellData
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIGroupMembersCellData
 * 【功能说明】“群成员”模块数据源，负责存放“群成员”模块所需的数据。
 *  目前本类主要负责存放“群成员”模块内所展示的群成员的信息。即 members 数组中存放的对象为 TUIGroupMemberCellData。
 */
@interface TUIGroupMembersCellData : NSObject
@property (nonatomic, strong) NSMutableArray *members;
@end

NS_ASSUME_NONNULL_END
