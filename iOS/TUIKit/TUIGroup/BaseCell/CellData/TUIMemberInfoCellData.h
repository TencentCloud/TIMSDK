//
//  TUIMemberInfoCellData.h
//  TUIGroup
//
//  Created by harvy on 2021/12/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIMemberInfoCellStyle) {
    TUIMemberInfoCellStyleNormal = 0,
    TUIMemberInfoCellStyleAdd    = 1
};

@interface TUIMemberInfoCellData : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) TUIMemberInfoCellStyle style;

@end

NS_ASSUME_NONNULL_END
