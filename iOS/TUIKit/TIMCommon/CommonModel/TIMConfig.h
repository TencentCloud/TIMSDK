//
//  TIMConfig.h
//  Pods
//
//  Created by cologne on 2023/3/14.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TUICore/TUIConfig.h>
#import "TIMCommonModel.h"
#import "TIMDefine.h"

@class TUIFaceCellData;
@class TUIFaceGroup;

NS_ASSUME_NONNULL_BEGIN

@interface TIMConfig : NSObject

+ (TIMConfig *)defaultConfig;
/**
 * In respect for the copyright of the emoji design, the Chat Demo/TUIKit project does not include the cutouts of large emoji elements. Please replace them
 * with your own designed or copyrighted emoji packs before the official launch for commercial use. The default small yellow face emoji pack is copyrighted by
 * Tencent Cloud and can be authorized for a fee. If you wish to obtain authorization, please submit a ticket to contact us.
 *
 * submit a ticket url：https://console.cloud.tencent.com/workorder/category?level1_id=29&level2_id=40&source=14&data_title=%E5%8D%B3%E6%97%B6%E9%80%9A%E4%BF%A1%20IM&step=1 (China mainland)
 * submit a ticket url：https://console.tencentcloud.com/workorder/category?level1_id=29&level2_id=40&source=14&data_title=Chat&step=1 (Other regions)
 */
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *faceGroups;

/**
 * 
 * The list of emoticons displayed after long-pressing the message on the chat interface
 */
@property(nonatomic, strong) NSArray<TUIFaceGroup *> *chatPopDetailGroups;


@property(nonatomic, assign) BOOL enableMessageBubble;

+ (BOOL)isClassicEntrance;
@end

NS_ASSUME_NONNULL_END
