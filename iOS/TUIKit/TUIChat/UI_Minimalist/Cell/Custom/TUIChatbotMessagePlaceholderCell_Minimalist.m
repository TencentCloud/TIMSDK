//
//  TUIChatbotMessagePlaceholderCell_Minimalist.m
//  TUIChat
//
//  Created by AI Assistant on 2025/1/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatbotMessagePlaceholderCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <ImageIO/ImageIO.h>
#import <SDWebImage/SDWebImage.h>

@interface TUIChatbotMessagePlaceholderCell_Minimalist ()
@property(nonatomic, strong) UIImageView *loadingImageView;
@property(nonatomic, strong) CADisplayLink *animationDisplayLink;
@property(nonatomic, assign) NSInteger currentFrameIndex;
@property(nonatomic, strong) NSArray<UIImage *> *animationFrames;
@end

@implementation TUIChatbotMessagePlaceholderCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLoadingImageView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self stopLoadingAnimation];
    _loadingImageView.hidden = YES;
}

- (void)setupLoadingImageView {
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
        _loadingImageView.hidden = NO;
        
        // Add to container instead of textView since we want it to be the main content
        [self.container addSubview:_loadingImageView];
        
        // Load GIF animation frames
        [self loadAnimationFrames];
    }
}

- (void)loadAnimationFrames {
    NSString *gifPath = TUIChatImagePath(@"chat_ai_loading.gif");
    if (!gifPath) {
        // If GIF not found, create simple loading animation
        [self createSimpleLoadingAnimation];
        return;
    }
    
    UIImage *image = [UIImage sd_imageWithGIFData:[NSData dataWithContentsOfFile:gifPath]];
    if (image && image.images.count > 0) {
        self.animationFrames = image.images;
    } else {
        [self createSimpleLoadingAnimation];
    }
}

- (void)createSimpleLoadingAnimation {
    // Create simple dot animation frames
    NSMutableArray *frames = [NSMutableArray array];
    NSArray *dotTexts = @[@"●", @"●●", @"●●●"];
    
    for (NSString *text in dotTexts) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 20), NO, [UIScreen mainScreen].scale);
        
        [text drawInRect:CGRectMake(0, 0, 30, 20) 
          withAttributes:@{
              NSFontAttributeName: [UIFont systemFontOfSize:14],
              NSForegroundColorAttributeName: [UIColor lightGrayColor]
          }];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (image) {
            [frames addObject:image];
        }
    }
    
    self.animationFrames = [frames copy];
}

- (void)startLoadingAnimation {
    if (self.animationFrames.count == 0) return;
    
    [self stopLoadingAnimation];
    
    self.currentFrameIndex = 0;
    self.animationDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimationFrame)];
    self.animationDisplayLink.preferredFramesPerSecond = 3; // 3 FPS for loading animation
    [self.animationDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopLoadingAnimation {
    if (self.animationDisplayLink) {
        [self.animationDisplayLink invalidate];
        self.animationDisplayLink = nil;
    }
}

- (void)updateAnimationFrame {
    if (self.animationFrames.count == 0) return;
    
    self.currentFrameIndex = (self.currentFrameIndex + 1) % self.animationFrames.count;
    self.loadingImageView.image = self.animationFrames[self.currentFrameIndex];
}

- (void)fillWithData:(TUIChatbotMessagePlaceholderCellData *)data {
    [super fillWithData:data];
    
    // Hide the text view since we only want to show loading animation
    self.textView.hidden = YES;
    
    // Setup and show loading animation
    [self setupLoadingImageView];
    
    if (data.isAITyping) {
        _loadingImageView.hidden = NO;
        [self startLoadingAnimation];
    } else {
        _loadingImageView.hidden = YES;
        [self stopLoadingAnimation];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Position loading image view in the center of the bubble
    if (!_loadingImageView.hidden) {
        CGFloat imageSize = 24.0;
        CGFloat containerWidth = self.container.frame.size.width;
        CGFloat containerHeight = self.container.frame.size.height;
        
        CGFloat imageX = (containerWidth - imageSize) / 2;
        CGFloat imageY = (containerHeight - imageSize) / 2;
        
        _loadingImageView.frame = CGRectMake(imageX, imageY, imageSize, imageSize);
    }
}

- (void)dealloc {
    [self stopLoadingAnimation];
}

@end 