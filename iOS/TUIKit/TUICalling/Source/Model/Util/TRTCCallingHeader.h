//
//  TRTCCallingHeader.h
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/8/4.
//  Copyright © 2020 Tencent. All rights reserved.
//


#ifndef TRTCCallingHeader_h
#define TRTCCallingHeader_h

#import "TUICommonUtil.h"

#define Version 4       //TUIkit 业务版本
#define APNs_Version 1  //推送版本
#define APNs_Business_NormalMsg  1  //普通消息推送
#define APNs_Business_Call       2  //音视频通话推送

#define TRTCLog(fmt, ...) TRTCCloudCallingAPILog(fmt, ##__VA_ARGS__)

/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif /* TRTCCallingHeader_h */
