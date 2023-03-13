//
//  TUIMemberInfoCellData_Minimalist.h
//  TUIGroup
//
//  Created by wyl on 2023/1/9.
//

#import <Foundation/Foundation.h>
#import "TUIMemberInfoCellData.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIMemberInfoCellData_Minimalist : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) TUIMemberInfoCellStyle style;
@end

NS_ASSUME_NONNULL_END
