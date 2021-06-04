/******************************************************************************
 *
 *  本文件声明了 TUIMessageDataProviderServiceProtocol 协议。
 *  本协议能够帮助您根据消息快速获取需要显示的字符串。具体信息请参照下文中对应委托函数的注释。
 *
 ******************************************************************************/
#import <Foundation/Foundation.h>
#import "THeader.h"
NS_ASSUME_NONNULL_BEGIN

@class TIMMessage;
@class TUIMessageCellData;
@class TUITextMessageCellData;
@class TUIFaceMessageCellData;
@class TUIImageMessageCellData;
@class TUIVoiceMessageCellData;
@class TUIVideoMessageCellData;
@class TUIFileMessageCellData;
@class TUISystemMessageCellData;
@class TUIRelayMessageCellData;

@protocol TUIMessageDataProviderServiceProtocol <NSObject>
- (NSString *)getShowName:(V2TIMMessage *)message;

/**
 *  获取待显示的字符串。
 *  根据传入的消息状态，返回一个与状态对应的字符串。
 *  返回的字符串包括以下几种：
 *  1、消息撤回 —— “您撤回了一条消息” / “XXX 撤回了一条消息”。
 *  2、多媒体消息 —— “[图片]” / “[视频]” / “[语音]” / “[文件]” / “[动画表情]”。
 *  3、群消息修改 —— “XXX 修改群名为 XXX” / “XXX 修改群简介为 XXX” / “XXX 修改群公告为 XXX” / “XXX 修改群主为 XXX”。
 *  4、群成员变动 —— “XXX 将 XXX 踢出群组” / “XXX 加入群组” / “XXX 邀请 XXX 加入群组” / “XXX 推出了群聊”
 *  本函数回根据传入的 message 状态返回响应的字符串信息。您可以使用得到的字符串，进行系统消息的显示，或是在消息列表的对应会话中展示消息概览。
 *
 *  @param message 传入的消息，类型为 TIMMessage。
 *
 *  @return 根据 message 信息返回的对应字符串。
 */
- (NSString *)getDisplayString:(V2TIMMessage *)message;

- (TUIMessageCellData *) getCellData:(V2TIMMessage *)message;

- (TUITextMessageCellData *) getTextCellData:(V2TIMMessage *)message  fromElem:(V2TIMTextElem *)elem;

- (TUIFaceMessageCellData *) getFaceCellData:(V2TIMMessage *)message  fromElem:(V2TIMFaceElem *)elem;

- (TUIImageMessageCellData *) getImageCellData:(V2TIMMessage *)message fromElem:(V2TIMImageElem *)elem;

- (TUIVoiceMessageCellData *) getVoiceCellData:(V2TIMMessage *)message fromElem:(V2TIMSoundElem *)elem;

- (TUIVideoMessageCellData *) getVideoCellData:(V2TIMMessage *)message fromElem:(V2TIMVideoElem *)elem;

- (TUIFileMessageCellData *) getFileCellData:(V2TIMMessage *)message fromElem:(V2TIMFileElem *)elem;

- (TUISystemMessageCellData *) getSystemCellData:(V2TIMMessage *)message fromElem:(V2TIMGroupTipsElem *)elem;

- (TUISystemMessageCellData *) getRevokeCellData:(V2TIMMessage *)message;

- (TUIRelayMessageCellData *)getMergerCellData:(V2TIMMessage *)message fromElem:(V2TIMMergerElem *)elem;
@end

NS_ASSUME_NONNULL_END
