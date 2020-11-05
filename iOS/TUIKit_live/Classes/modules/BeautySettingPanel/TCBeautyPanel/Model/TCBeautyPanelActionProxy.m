//
//  TCBeautyPanelActionProxy.m
//  TCBeautyPanel
//
//  Created by cui on 2019/12/23.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TCBeautyPanelActionProxy.h"

@interface NSObject (BeautyManager)
- (id)getBeautyManager;
- (void)setFilterConcentration:(float)level;
- (void)setSpecialRatio:(float)level;
@end

NS_INLINE BOOL isFilterConcentrationSetter(SEL selector) {
    return strcmp(sel_getName(selector), sel_getName(@selector(setFilterConcentration:))) == 0;
}

@implementation TCBeautyPanelActionProxy
{
    __weak id _object;
    __weak id _beautyManager;
    SEL       _filterConcentrationAlternativeSetter;
}

+ (instancetype)proxyWithSDKObject:(id)object {
    return [[TCBeautyPanelActionProxy alloc] initWithObject:object
                                      filterConcentrationSetter:@selector(setSpecialRatio:)];
}

+ (instancetype)proxyWithSDKObject:(id)object filterConcentrationSetter:(SEL)setter {
    return [[TCBeautyPanelActionProxy alloc] initWithObject:object
                                      filterConcentrationSetter:setter];
}

- (instancetype)initWithObject:(id)object filterConcentrationSetter:(SEL)setter {
    _filterConcentrationAlternativeSetter = setter;
    if (![object respondsToSelector:@selector(getBeautyManager)]) {
        NSLog(@"%s failed, %@ doesn't has getBeautyManager method", __PRETTY_FUNCTION__, object);
        return nil;
    }
    id beautyManager = [object getBeautyManager];
    if (![beautyManager isKindOfClass:NSClassFromString(@"TXBeautyManager")]) {
        NSLog(@"%s failed, type mismatch of object.getBeautyManager(%@)", __PRETTY_FUNCTION__, object);
        return nil;
    }
    _object = object;
    _beautyManager = beautyManager;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([_beautyManager respondsToSelector:sel]) {
        return [_beautyManager methodSignatureForSelector:sel];
    } else if ([_object respondsToSelector:sel])  {
        return [_object methodSignatureForSelector:sel];
    } else if (_filterConcentrationAlternativeSetter && isFilterConcentrationSetter(sel)) {
        return [_object methodSignatureForSelector:_filterConcentrationAlternativeSetter];
    }

    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector;
    if ([_beautyManager respondsToSelector: selector]) {
        [invocation invokeWithTarget:_beautyManager];
    } else if ([_object respondsToSelector: selector]) {
        [invocation invokeWithTarget:_object];
    } else if (_filterConcentrationAlternativeSetter && isFilterConcentrationSetter(selector)) {
        invocation.selector = _filterConcentrationAlternativeSetter;
        [invocation invokeWithTarget:_object];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_beautyManager respondsToSelector:aSelector]) {
        return YES;
    }
    if ([_object respondsToSelector:aSelector]) {
        return YES;
    }
    if (_filterConcentrationAlternativeSetter && isFilterConcentrationSetter(aSelector)) {
        return [_object respondsToSelector:_filterConcentrationAlternativeSetter];
    }
    return NO;
}

@end

@implementation TCBeautyPanel (SDK)
+ (instancetype)beautyPanelWithFrame:(CGRect)frame SDKObject:(id)object {
    return [TCBeautyPanel beautyPanelWithFrame:frame
                            actionPerformer:[TCBeautyPanelActionProxy proxyWithSDKObject:object]];
}
@end
