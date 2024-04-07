
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**

 * This document declares the voice message recording component
 * Voice view, that is, a view that provides guidance and result prompts when a user records a voice message.
 * This file contains the TUIRecordView class.
 * This class is responsible for providing operational guidance to the user when the user is recording, such as indicating the recording volume, reminding the
 * current recording status, etc.
 */
#import <UIKit/UIKit.h>
#import "TUIChatDefine.h"

@interface TUIRecordView : UIView

/**
 *  Icon view for recording
 *  This icon contains the corresponding icons under each volume level (a total of 8 volume indications from 1 to 8).
 */
@property(nonatomic, strong) UIImageView *recordImage;

/**
 *  Label for displaying tips
 *  Prompt the user about the current recording status. Such as "release to send", "swipe up to cancel sending", "talk time is too short", etc.
 */
@property(nonatomic, strong) UILabel *title;

@property(nonatomic, strong) UIView *background;

@property(nonatomic, strong) UILabel *timeLabel;

/**
 *  Sets the volume of the current recording.
 *  It is convenient for the image in the recording icon view to change according to the volume.
 *  For example: when power < 25, use the "one grid" icon; when power > 25, calculate the icon format according to a certain formula and replace the current
 * icon.
 */
- (void)setPower:(NSInteger)power;

- (void)setStatus:(RecordStatus)status;
@end
