 /**
  *
  * 本文件声明了用于实现“更多”单元的模块。
  * 更多单元，即在点击聊天界面右下角“+”后出现的 UI 界面。
  * 目前更多单元提供拍摄、视频、图片、文件四种多媒体发送功能，您也可以根据您的需求自定义。
  *
  * This document declares modules for implementing "more" units.
  * More units, that is, the UI interface that appears after clicking the "+" in the lower right corner of the chat interface.
  * At present, more units provide four multimedia sending functions of camera, video, picture, and file, and you can also customize it according to your needs.
  */

#import <UIKit/UIKit.h>
#import "TUIInputMoreCellData.h"

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIInputMoreCell
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIInputMoreCell : UICollectionViewCell

/**
 *  更多单元对应的图标，从 TUIInputMoreCellData 的 image 中获取。
 *  各个单元的图标有所不同，用于形象表示该单元所对应的功能。
 *
 *  The icons corresponding to more cells are obtained from the image of TUIInputMoreCellData.
 *  The icons of each unit are different, which are used to visually represent the corresponding functions of the unit.
 */
@property (nonatomic, strong) UIImageView *image;

/**
 *  更多单元对应的标签。
 *  其文本内容从 TUIInputMoreCellData 的 title 中获取。
 *  各个单元的名称有所不同（比如拍摄、录像、文件、相册等），用于在图标下方以文字形式展示单元对应的功能。
 *
 *  The label corresponding to more cells, the text content of which is obtained from the title of TUIInputMoreCellData.
 *  The names of each unit are different (such as camera, video, file, album, etc.), which are used to display the corresponding functions of the unit in text form below the icon.
 */
@property (nonatomic, strong) UILabel *title;


@property (nonatomic, strong) TUIInputMoreCellData *data;

/**
 * 是否禁用封装在 TUIKit 内部的默认的选中行为，如群直播默认创建直播间等行为，默认：NO
 * Whether to disable the default selection behavior encapsulated in TUIKit, such as group live broadcast by default to create live room and other behaviors, default: NO
 */
@property (nonatomic, assign) BOOL disableDefaultSelectAction;


- (void)fillWithData:(TUIInputMoreCellData *)data;

+ (CGSize)getSize;

@end



