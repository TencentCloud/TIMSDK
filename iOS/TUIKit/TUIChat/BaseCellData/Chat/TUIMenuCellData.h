
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIMenuCellData
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIMenuCellData : NSObject

/**
 *  Access path for grouped thumbnails in grouping units
 */
@property(nonatomic, strong) NSString *path;

@property(nonatomic, assign) BOOL isSelected;
@end

NS_ASSUME_NONNULL_END
