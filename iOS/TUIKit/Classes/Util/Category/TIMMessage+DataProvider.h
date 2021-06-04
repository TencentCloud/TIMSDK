/*******
 *
 *  本类实现的目的是提高复用率，使已有的 MessageController 中的代码封装于此，使代码阅读起来更加简洁易懂，同时在修改时也可达到同时修改的目的。
 *  同时为将来 TUIKit 的第三方使用者提供一个较为方便的数据使用方式，省去了很多数据转换的步骤。
 *  
 *  在使用时，只需在拉取到 TIMMessage 后，通过 [myMessage functionName] 即可调用。
 *  对于本类中获取各类 cellData 的方法， 由于 TIMMessage 中包含的元素可能会十分复杂，所以需要使用者在使用之前判断 TIMMessage 中 Elem 的类型，再另行调用。
 *
 *******/

#import <Foundation/Foundation.h>
#import "THeader.h"

NS_ASSUME_NONNULL_BEGIN
@class TUITextMessageCellData;
@class TUIFaceMessageCellData;
@class TUIImageMessageCellData;
@class TUIVoiceMessageCellData;
@class TUIVideoMessageCellData;
@class TUIFileMessageCellData;
@class TUISystemMessageCellData;

@interface V2TIMMessage (DataProvider)

/**
 *  获取消息发送者展示名称
 */
- (NSString *)getShowName;

/**
 *  根据消息类型，获取需要展示的字符串
 *  比如对于图片消息，返回“[图片]”，对于退群消息，返回“XXX 退出了群聊。”
 */
- (NSString *)getDisplayString;

//- (id) transToCellData;

/***************************************
 *
 * 本函数为优化过的方法，可以直接将消息内的 Elem 转化为对应的 cellData，类型判定由本方法直接完成，无需您的进一步判断。
 * 使用方法，对于一个 TIMMessage，直接使用下列示例代码即可：
 * TIMElem *elem = [myMessage getElem:index];
 * TUIXXXMessageCellData *data = [myMessage cellDataFromElem:elem];
 * 其中，index 为元素在 TIMMessage 中对应的索引号。
 * 目前支持 文本、视频、表情、文件、图片、语音、系统消息7类。
 *
 ***************************************/

-(id)cellData;



/***************************************
 *
 *  作为使用者，当您需要获得多媒体消息和系统消息时，直接使用上面的函数即可。
 *  以下下函数用于多媒体消息的封装，使其在逻辑层面上独立，便于修改，但不建议您直接使用。
 *
 *  下面的函数功能相似，都是将 TIMMessage 中的 XXXelem 转化为 XXXCellData，便于显示与操作。
 *  本函数使用前需要使用者提前判断传入的 Elem 是否为正确格式，例如 [elem isKindOfClass:[TIMXXXXElem class]]
 *  理论上来说，对于任何符合格式的 Elem，都会返回一个对应的 CellData。但只有调用本方法的 TIMMessage 包含的 Elem，才能得到正确无误的结果。
 *
 ***************************************/

/**
 *  根据输入的 TIMTextElem 返回 TUITextMessageCellData。
 */
- (TUITextMessageCellData *) textCellDataFromElem:(V2TIMTextElem *)elem;

/**
 *  根据输入的 TIMFaceElem 返回 TUITextMessageCellData。
 */
- (TUIFaceMessageCellData *) faceCellDataFromElem:(V2TIMFaceElem *)elem;

/**
 *  根据输入的 TIMImageElem 返回 TUIImageMessageCellData。
 */
- (TUIImageMessageCellData *) imageCellDataFromElem:(V2TIMImageElem *) elem;

/**
 *  根据输入的 TIMSoundElem 返回 TIMSoundElem。
 */
- (TUIVoiceMessageCellData *) voiceCellDataFromElem:(V2TIMSoundElem *)elem;

/**
 *  根据输入的 TIMVideoElem 返回 TUIVideoMessageCellData。
 */
- (TUIVideoMessageCellData *) videoCellDataFromElem:(V2TIMVideoElem *)elem;

/**
 *  根据输入的 TIMFileElem 返回 TUIFileMessageCellData。
 */
- (TUIFileMessageCellData *) fileCellDataFromElem:(V2TIMFileElem *)elem;

/**
 * 返回 TUISystemMessageCellData
*/
- (TUISystemMessageCellData *) revokeCellData;

//TODO  实现 group_create 等 TUIKit 中的系统/群组消息，方便今后修改。

@end

NS_ASSUME_NONNULL_END
