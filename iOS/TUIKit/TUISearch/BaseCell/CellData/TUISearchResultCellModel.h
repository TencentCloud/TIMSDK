//
//  TUISearchResultCellModel.h
//  Pods
//
//  Created by harvy on 2020/12/24.
//

#import <Foundation/Foundation.h>
#import "TUIConfig.h"

@import UIKit;
NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultCellModel : NSObject

@property (nonatomic, copy) NSString * __nullable title;
@property (nonatomic, copy) NSString * __nullable details;
@property (nonatomic, strong) NSAttributedString * __nullable titleAttributeString;
@property (nonatomic, strong) NSAttributedString * __nullable detailsAttributeString;

@property (nonatomic, copy) NSString * __nullable avatarUrl;
@property (nonatomic, assign) TUIKitAvatarType avatarType;
@property (nonatomic, strong) UIImage * __nullable avatarImage;
@property (nonatomic, copy) NSString * __nullable groupID;
@property (nonatomic, copy) NSString * __nullable groupType;

@property (nonatomic, assign) BOOL hideSeparatorLine;
@property (nonatomic, strong) id context;

@end

NS_ASSUME_NONNULL_END
