/**
 *
 * 本文件声明了用于实现“更多”单元的模块。
 * - "更多单元"，即在点击聊天界面右下角“+”后出现的若干单元。
 * - 目前"更多单元"提供拍摄、视频、图片、文件四种多媒体发送功能，您也可以自定义。
 * - TUIInputMoreCellData 负责存储一系列“更多”单元所需的信息。
 *
 * This document declares modules for implementing "more" units.
 * - "More units", that is, several units that appear after clicking the "+" in the lower right corner of the chat interface.
 * - At present, "More Units" provides four multimedia sending functions of shooting, video, picture and file, and you can also customize it.
 * - TUIInputMoreCellData is responsible for storing the information needed for a series of "more" cells.
 */

#import <Foundation/Foundation.h>
@import UIKit;
NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIInputMoreCellData_Minimalist
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【模块名称】TUIInputMoreCellData_Minimalist
 * 【功能说明】"更多单元"数据源
 *  - "更多单元"负责在"更多视图"中显示，向用户展示"更多视图"中包含的功能。同时作为各个功能的入口，响应用户的交互事件。
 *  - 数据源则负责存储一系列“更多单元"所需的信息。
 *
 * 【Module name】TUIInputMoreCellData_Minimalist
 * 【Function description】"More units" data source
 *  - "More Units" is responsible for displaying in "More Views", showing the user the functionality contained in "More Views". At the same time, it serves as the entrance of each function and responds to user interaction events.
 *  - The data source is responsible for storing the information needed for a series of "more units".
 */
@interface TUIInputMoreCellData_Minimalist : NSObject

/**
 *  UI 扩展 view
 *  UI extension view
 */
@property (nonatomic, strong) UIView *extentionView;

/**
 *  唯一标识 key
 *
 *  Unique identification key
 */
@property (nonatomic, strong) NSString *key;

/**
 *  单元图标
 *  各个单元的图标有所不同，用于形象表示该单元所对应的功能。
 *
 *  Image for single unit
 *  The icons of each unit are different, which are used to visually represent the function corresponding to the unit
 */
@property (nonatomic, strong) UIImage *image;

/**
 *  单元名称
 *  各个单元的名称有所不同（比如拍摄、录像、文件、相册等），用于在图标下方以文字形式展示单元对应的功能。
 *
 *  Name for single unit
 *  The names of each unit are different (such as Photo, Video, File, Album, etc.), which are used to display the corresponding functions of the unit in text form below the icon.
 */
@property (nonatomic, strong) NSString *title;

/**
 *  “相册”单元所对应的数据源。用于存放相册单元所需的各类信息与数据。
 *  The data source corresponding to the "Album" unit. It is used to store all kinds of information and data required by the album unit.
 */
@property (class, nonatomic, assign) TUIInputMoreCellData_Minimalist *photoData;

/**
 *  “拍摄”单元所对应的数据源。用于存放拍摄单元所需的各类信息与数据。
 *  The data source corresponding to the "Photo" unit. It is used to store all kinds of information and data required by the shooting unit.
 */
@property (class, nonatomic, assign) TUIInputMoreCellData_Minimalist *pictureData;

/**
 *  “视频”单元所对应的数据源。用于存放视频单元所需的各类信息与数据。
 *  The data source corresponding to the "Video" unit. It is used to store all kinds of information and data required by the video unit.
 */
@property (class, nonatomic, assign) TUIInputMoreCellData_Minimalist *videoData;

/**
 *  “文件”单元所对应的数据源。用于存放文件单元所需的各类信息与数据。
 *  The data source corresponding to the "File" unit. It is used to store all kinds of information and data required by the file unit.
 */
@property (class, nonatomic, assign) TUIInputMoreCellData_Minimalist *fileData;

+ (void)resetAllCelData;

@end

NS_ASSUME_NONNULL_END
