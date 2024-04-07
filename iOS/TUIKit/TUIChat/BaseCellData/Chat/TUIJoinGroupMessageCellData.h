
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *
 *  This file declares the TUIJoinGroupMessageCellData class.
 *  This document is responsible for realizing the function of the small gray bar for entering the group, and can also be further extended to a group message
 * unit with a single operator. That is, this file can highlight the operator's nickname in blue and provide a response interface for the highlighted part in
 * blue.
 */
#import <TIMCommon/TUISystemMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIJoinGroupMessageCellData : TUISystemMessageCellData

/**
 *
 *  Operator nickname. For example, "Tom joined the group", the variable content is "Tom"
 */
@property(nonatomic, strong) NSString *opUserName;

/**
 *  The nickname of the operator.
 */
@property(nonatomic, strong) NSMutableArray<NSString *> *userNameList;

/**
 *  Operator Id.
 */
@property(nonatomic, strong) NSString *opUserID;

/**
 *  List of the operator IDs.
 */
@property(nonatomic, strong) NSMutableArray<NSString *> *userIDList;

@end

NS_ASSUME_NONNULL_END
