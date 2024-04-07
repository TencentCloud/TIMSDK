
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/******************************************************************************
 *
 *  This file declares the TUIMemberCellData class.
 *  It provides a data source for the TUIMemberCell class, which is mainly used in the message read member list interface, etc.
 *
 ******************************************************************************/

#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMemberDescribeCellData : TUICommonCellData

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) UIImage *icon;

@end


@interface TUIMemberCellData : TUICommonCellData

@property(nonatomic, copy) NSString *title;   // member's display name
@property(nonatomic, copy) NSURL *avatarUrL;  // member's avatar image url
@property(nonatomic, copy) NSString *detail;  // optional, used to display more info
@property(nonatomic, copy) NSString *userID;

- (instancetype)initWithUserID:(nonnull NSString *)userID
                      nickName:(nullable NSString *)nickName
                  friendRemark:(nullable NSString *)friendRemark
                      nameCard:(nullable NSString *)nameCard
                     avatarUrl:(nonnull NSString *)avatarUrl
                        detail:(nullable NSString *)detail;

@end

NS_ASSUME_NONNULL_END
