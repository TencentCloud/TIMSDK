/**
 *  本文件声明了群创建成功后，跳转到消息界面时所展示的 “xxx 创建群聊“ 消息 cell
 *  This document declares that after the group is successfully created, the "xxx create group chat" message cell displayed when jumping to the message interface
 */

#import "TUIGroupCreatedCellData.h"
#import "TUISystemMessageCell.h"

@interface TUIGroupCreatedCell : TUISystemMessageCell

- (void)fillWithData:(TUIGroupCreatedCellData *)data;

@end
