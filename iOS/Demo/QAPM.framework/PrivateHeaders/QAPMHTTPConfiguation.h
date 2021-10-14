//
//  QAPMHTTPConfiguation.h
//  QAPM
//
//  Created by Cass on 2019/6/11.
//  Copyright © 2019 cass. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QAPMHTTPConfiguation : NSObject

/// 是否允许移动网络进行上报
@property (nonatomic) BOOL allowsCellularAccess;

@end

NS_ASSUME_NONNULL_END
