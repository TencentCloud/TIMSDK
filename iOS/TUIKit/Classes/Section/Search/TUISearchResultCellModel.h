//
//  TUISearchResultCellModel.h
//  Pods
//
//  Created by harvy on 2020/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultCellModel : NSObject

@property (nonatomic, copy) NSString * __nullable title;
@property (nonatomic, copy) NSString * __nullable details;
@property (nonatomic, strong) NSAttributedString * __nullable titleAttributeString;
@property (nonatomic, strong) NSAttributedString * __nullable detailsAttributeString;

@property (nonatomic, copy) NSString * __nullable avatarUrl;
@property (nonatomic, strong) UIImage * __nullable avatarImage;
@property (nonatomic, copy) NSString * __nullable groupID;          // 群组id

// 上下文信息, 可以用来传值
@property (nonatomic, strong) id context;

@end

NS_ASSUME_NONNULL_END
