//
//  QAPMHTTPManager.h
//  QAPM
//
//  Created by Cass on 2019/6/11.
//  Copyright © 2019 cass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QAPMHTTPConfiguation.h"

NS_ASSUME_NONNULL_BEGIN

@interface QAPMHTTPMonitor : NSObject

+ (instancetype)shared;

- (void)start;

- (void)startWithConfiguration:(QAPMHTTPConfiguation * _Nullable)configuration;

@end

NS_ASSUME_NONNULL_END
