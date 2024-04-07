
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
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
 *  The icons corresponding to more cells are obtained from the image of TUIInputMoreCellData.
 *  The icons of each unit are different, which are used to visually represent the corresponding functions of the unit.
 */
@property(nonatomic, strong) UIImageView *image;

/**
 *  The label corresponding to more cells, the text content of which is obtained from the title of TUIInputMoreCellData.
 *  The names of each unit are different (such as camera, video, file, album, etc.), which are used to display the corresponding functions of the unit in text
 * form below the icon.
 */
@property(nonatomic, strong) UILabel *title;

@property(nonatomic, strong) TUIInputMoreCellData *data;

/**
 * Whether to disable the default selection behavior encapsulated in TUIKit, such as group live broadcast by default to create live room and other behaviors,
 * default: NO
 */
@property(nonatomic, assign) BOOL disableDefaultSelectAction;

- (void)fillWithData:(TUIInputMoreCellData *)data;

+ (CGSize)getSize;

@end
