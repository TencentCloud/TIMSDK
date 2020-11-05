// Copyright (c) 2019 Tencent. All rights reserved.

#ifndef TCPituMotionManager_h
#define TCPituMotionManager_h

#import <Foundation/Foundation.h>
@interface TCPituMotion : NSObject
@property (readonly, nonatomic) NSString *identifier;
@property (readonly, nonatomic) NSString *name;
@property (readonly, nonatomic) NSURL *url;
- (instancetype)initWithId:(NSString *)identifier name:(NSString *)name url:(NSString *)address;
@end

@interface TCPituMotionManager : NSObject
@property (readonly, nonatomic) NSArray<TCPituMotion *> * motionPasters;
@property (readonly, nonatomic) NSArray<TCPituMotion *> * cosmeticPasters;
@property (readonly, nonatomic) NSArray<TCPituMotion *> * gesturePasters;
@property (readonly, nonatomic) NSArray<TCPituMotion *> * backgroundRemovalPasters;

+ (instancetype)sharedInstance;
- (TCPituMotion *)motionWithIdentifier:(NSString *)identifier;

@end

#endif /* Header_h */
