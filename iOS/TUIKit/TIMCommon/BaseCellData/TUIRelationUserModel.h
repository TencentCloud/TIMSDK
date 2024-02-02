//
//  TUIRelationUserModel.h
//  TIMCommon
//
//  Created by wyl on 2023/12/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIRelationUserModel : NSObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *friendRemark;
@property(nonatomic, copy) NSString *nameCard;
@property(nonatomic, copy) NSString *nickName;
@property(nonatomic, copy) NSString *faceURL;

- (NSString *)getDisplayName;

@end

NS_ASSUME_NONNULL_END
