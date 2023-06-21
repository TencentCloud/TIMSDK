//
//  TUIGroupCreateController_Minimalist.h
//  TUIContact
//
//  Created by wyl on 2022/8/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupCreateController_Minimalist : UIViewController
@property(nonatomic, strong) V2TIMGroupInfo *createGroupInfo;
@property(nonatomic, strong) NSArray<TUICommonContactSelectCellData *> *createContactArray;
@property(nonatomic, copy) void (^submitCallback)(BOOL isSuccess, V2TIMGroupInfo *info, UIImage *submitShowImage);
@end

NS_ASSUME_NONNULL_END
