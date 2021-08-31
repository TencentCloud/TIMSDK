//
//  MsgTableCellView.m
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/23.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import "MsgTableCellView.h"

@implementation MsgTableCellView
{
    NSImageView *_imageView;
    NSTextField *_textFeild;
    NSTextField *_textSubFeild;
    NSTextField *_timeTextFeild;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _imageView = [[NSImageView alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.height, self.bounds.size.height - 10)];
        [self addSubview:_imageView];
        
        _textFeild = [[NSTextField alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x + _imageView.frame.size.width + 20, 5, self.bounds.size.width - (_imageView.frame.origin.x + _imageView.frame.size.width + 20), self.bounds.size.height / 2 - 5)];
        _textFeild.editable = NO;
        _textFeild.bezeled = NO;
        _textFeild.backgroundColor = [NSColor clearColor];
        [self addSubview:_textFeild];
        
        _textSubFeild = [[NSTextField alloc] initWithFrame:CGRectMake(_textFeild.frame.origin.x, self.bounds.size.height / 2 + 5, _textFeild.frame.size.width, self.bounds.size.height / 2 - 5)];
        _textSubFeild.editable = NO;
        _textSubFeild.bezeled = NO;
        _textSubFeild.backgroundColor = [NSColor clearColor];
        [self addSubview:_textSubFeild];
        
        _timeTextFeild = [[NSTextField alloc] initWithFrame:CGRectMake(self.bounds.size.width - 60, 5,50, 30)];
        _timeTextFeild.editable = NO;
        _timeTextFeild.bezeled = NO;
        _timeTextFeild.backgroundColor = [NSColor clearColor];
        _timeTextFeild.stringValue = @"00:12";
        [self addSubview:_timeTextFeild];
        
        NSTextField *lineView = [[NSTextField alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
        lineView.backgroundColor = [NSColor grayColor];
        lineView.alphaValue = 0.5;
        [self addSubview:lineView];
    }
    return self;
}

-(BOOL)isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)setHeader:(NSImage *)image msg:(NSString *)msg subMsg:(NSString *)subMsg time:(NSString *)time{
    _imageView.image = image;
    _textFeild.stringValue = msg;
    _textSubFeild.stringValue = subMsg;
    _timeTextFeild.stringValue = time;
}

@end
