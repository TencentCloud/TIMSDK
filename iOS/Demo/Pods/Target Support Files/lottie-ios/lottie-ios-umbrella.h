#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Lottie/LOTAnimatedControl.h"
#import "Lottie/LOTAnimatedSwitch.h"
#import "Lottie/LOTAnimationCache.h"
#import "Lottie/LOTAnimationTransitionController.h"
#import "Lottie/LOTAnimationView.h"
#import "Lottie/LOTAnimationView_Compat.h"
#import "Lottie/LOTBlockCallback.h"
#import "Lottie/LOTCacheProvider.h"
#import "Lottie/LOTComposition.h"
#import "Lottie/LOTInterpolatorCallback.h"
#import "Lottie/LOTKeypath.h"
#import "Lottie/Lottie.h"
#import "Lottie/LOTValueCallback.h"
#import "Lottie/LOTValueDelegate.h"

FOUNDATION_EXPORT double LottieVersionNumber;
FOUNDATION_EXPORT const unsigned char LottieVersionString[];

