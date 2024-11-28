// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import <Foundation/Foundation.h>

static CGFloat Vec2Len(CGPoint v) { return sqrt(v.x * v.x + v.y * v.y); }

static CGPoint Vec2Mul(CGPoint v, CGFloat k) { return CGPointMake(v.x * k, v.y * k); }

static CGPoint Vec2AddVector(CGPoint v, CGPoint va) { return CGPointMake(v.x + va.x, v.y + va.y); }

static CGPoint Vec2AddOffset(CGPoint v, CGFloat k) { return CGPointMake(v.x + k, v.y + k); }

static CGFloat Vec2Degree(CGPoint v1, CGPoint v2) { return atan2(v2.y, v2.x) - atan2(v1.y, v1.x); }

static CGPoint Vec2Rotate(CGPoint p, CGFloat r) {
    CGFloat s = sin(r);
    CGFloat c = cos(r);
    return CGPointMake(p.x * c - p.y * s, p.x * s + p.y * c);
}
