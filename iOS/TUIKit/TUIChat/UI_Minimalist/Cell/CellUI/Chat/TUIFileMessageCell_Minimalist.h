#import "TUIFileMessageCellData_Minimalist.h"
#import "TUIBubbleMessageCell_Minimalist.h"

@interface TUIFileMessageCell_Minimalist : TUIBubbleMessageCell_Minimalist

/**
 *  文件气泡视图
 *  用来在UI上包裹消息
 *
 *  File bubble view, used to wrap messages on the UI
 */
@property (nonatomic, strong) UIImageView *bubble;

/**
 *  文件名标签
 *  作为文件消息的主要标签，展示文件信息（包含后缀）。
 *
 *  Label for displaying filename
 *  As the main label of the file message, it displays the file information (including the suffix).
 */
@property (nonatomic, strong) UILabel *fileName;

/**
 *  文件长度
 *  作为文件消息的小标签，进一步展示文件的次要信息。
 *
 *  Label for displaying file size
 *  As the secondary label of the file message, it further displays the secondary information of the file.
 */
@property (nonatomic, strong) UILabel *length;

/**
 *  文件图标
 *  File icon
 */
@property (nonatomic, strong) UIImageView *fileImage;

/**
 *  下载图标
 *  Download icon
 */
@property (nonatomic, strong) UIImageView *downloadImage;

@property TUIFileMessageCellData_Minimalist *fileData;

- (void)fillWithData:(TUIFileMessageCellData_Minimalist *)data;
@end
