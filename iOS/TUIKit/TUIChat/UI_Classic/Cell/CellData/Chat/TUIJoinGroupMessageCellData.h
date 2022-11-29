/**
 *
 *  本文件声明了 TUIJoinGroupMessageCellData 类。
 *  本文件负责实现入群小灰条的功能，同时也能进一步扩展为所有操作者为单人的群组消息单元。
 *  即本文件能够实现将操作者昵称蓝色高亮，并提供蓝色高亮部分的响应接口。
 *
 *  This file declares the TUIJoinGroupMessageCellData class.
 *  This document is responsible for realizing the function of the small gray bar for entering the group, and can also be further extended to a group message unit with a single operator.
 *  That is, this file can highlight the operator's nickname in blue and provide a response interface for the highlighted part in blue.
 */
#import "TUISystemMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIJoinGroupMessageCellData : TUISystemMessageCellData

/**
 *  操作者昵称。例如 “小明加入了群组”，则该变量内容为“小明”
 *
 *  Operator nickname. For example, "Tom joined the group", the variable content is "Tom"
 */
@property (nonatomic, strong) NSString *opUserName;

/**
 *  被操作者昵称。
 *  The nickname of the operator.
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *userNameList;

/**
 *  操作者 Id。
 *  Operator Id.
 */
@property (nonatomic, strong) NSString *opUserID;

/**
 *  被操作者 Id 列表。
 *  List of the operator IDs.
 */
@property (nonatomic, strong) NSMutableArray<NSString *>*userIDList;

@end

NS_ASSUME_NONNULL_END
