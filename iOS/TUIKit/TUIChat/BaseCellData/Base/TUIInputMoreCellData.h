
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 * This document declares modules for implementing "more" units.
 * - "More units", that is, several units that appear after clicking the "+" in the lower right corner of the chat interface.
 * - At present, "More Units" provides four multimedia sending functions of shooting, video, picture and file, and you can also customize it.
 * - TUIInputMoreCellData is responsible for storing the information needed for a series of "more" cells.
 */

#import <Foundation/Foundation.h>
@import UIKit;
NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIInputMoreCallback)(NSDictionary *param);

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUIInputMoreCellData
//
/////////////////////////////////////////////////////////////////////////////////

/**
 * 【Module name】TUIInputMoreCellData
 * 【Function description】"More units" data source
 *  - "More Units" is responsible for displaying in "More Views", showing the user the functionality contained in "More Views". At the same time, it serves as
 * the entrance of each function and responds to user interaction events.
 *  - The data source is responsible for storing the information needed for a series of "more units".
 */
@interface TUIInputMoreCellData : NSObject

/**
 *  Image for single unit
 *  The icons of each unit are different, which are used to visually represent the function corresponding to the unit
 */
@property(nonatomic, strong) UIImage *image;

/**
 *  Name for single unit
 *  The names of each unit are different (such as Photo, Video, File, Album, etc.), which are used to display the corresponding functions of the unit in text
 * form below the icon.
 */
@property(nonatomic, strong) NSString *title;

/**
 * Callback for clicked
 */
@property(nonatomic, copy) TUIInputMoreCallback onClicked;

/**
 *  Prioriy for displaying in more menu list
 *  The larger the value, the higher the front in list
 */
@property(nonatomic, assign) NSInteger priority;

@end

NS_ASSUME_NONNULL_END
