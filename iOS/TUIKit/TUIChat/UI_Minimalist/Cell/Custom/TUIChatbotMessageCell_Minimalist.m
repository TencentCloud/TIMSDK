//
//  TUIChatbotMessageCell_Minimalist.m
//  TUIChat
//
//  Created by Yiliang Wang on 2025/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIChatbotMessageCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <ImageIO/ImageIO.h>
#import <SDWebImage/SDWebImage.h>

@interface TUIChatbotMessageCell_Minimalist ()
@property(nonatomic, strong) UIImageView *loadingImageView;
@property(nonatomic, strong) CADisplayLink *animationDisplayLink;
@property(nonatomic, assign) NSInteger currentFrameIndex;
@property(nonatomic, strong) NSArray<UIImage *> *animationFrames;
@property(nonatomic, strong) dispatch_source_t currentTimer;
@end

@implementation TUIChatbotMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Add notification listener for immediate stop rendering
        self.textView.selectable = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onImmediateStopRendering:)
                                                     name:@"TUIChatbotImmediateStopRendering"
                                                   object:nil];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    // Reset loading image view state to prevent cell reuse issues
    [self stopLoadingAnimation];
    if (_loadingImageView) {
        _loadingImageView.hidden = YES;
        _loadingImageView.image = nil;
    }
    
}

- (void)onImmediateStopRendering:(NSNotification *)notification {
    // Check if this notification is for this specific cell
    TUIMessageCellData *targetCellData = notification.userInfo[@"cellData"];
    if (targetCellData && targetCellData == self.bubbleData) {
        [self immediateStopRendering];
    }
}

- (void)immediateStopRendering {
    // Immediately stop timer
    if (self.currentTimer) {
        [self stopTimer:self.currentTimer];
        self.currentTimer = nil;
        
        // Also clear data.timer if it matches current timer
        TUIChatbotMessageCellData *data = (TUIChatbotMessageCellData *)self.bubbleData;
        if (data && [data isKindOfClass:[TUIChatbotMessageCellData class]]) {
            data.timer = nil;
        }
    }
    
    // Stop loading animation
    [self stopLoadingAnimation];
    
    // Hide loading image
    self.loadingImageView.hidden = YES;
    
    NSLog(@"TUIChatbotMessageCell_Minimalist: Immediate stop rendering executed");
}

- (void)setupLoadingImageView {
    if (!_loadingImageView) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.contentMode = UIViewContentModeScaleAspectFit;
        _loadingImageView.hidden = YES;
        [self.textView addSubview:_loadingImageView];
        
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
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, [UIScreen mainScreen].scale);
        
        [text drawInRect:CGRectMake(0, 0, 20, 20) 
          withAttributes:@{
              NSFontAttributeName: [UIFont systemFontOfSize:12],
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

- (void)updateLoadingImageViewLayout {
    if (!_loadingImageView || _loadingImageView.hidden) return;
    
    // Get current displayed text length
    NSString *displayedText = self.textView.text;
    if (displayedText.length == 0) return;
    
    // Calculate actual text rendering position
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    NSTextContainer *textContainer = self.textView.textContainer;
    
    // Get position of the last character
    NSRange lastCharRange = NSMakeRange(displayedText.length - 1, 1);
    CGRect lastCharRect = [layoutManager boundingRectForGlyphRange:lastCharRange inTextContainer:textContainer];
    
    // Set loading image position to the right of the last character
    CGFloat imageSize = 16.0;
    CGFloat imageX = lastCharRect.origin.x + lastCharRect.size.width + 4; // 4px spacing after last character
    CGFloat imageY = lastCharRect.origin.y + (lastCharRect.size.height - imageSize) / 2; // Vertically centered
    
    // Convert to textView coordinate system
    CGFloat textViewX = self.textView.textContainerInset.left + imageX;
    CGFloat textViewY = self.textView.textContainerInset.top + imageY;
    
    _loadingImageView.frame = CGRectMake(textViewX, textViewY, imageSize, imageSize);
    if (isRTL()) {
        [_loadingImageView resetFrameToFitRTL];
    }
}

- (void)fillWithData:(TUIChatbotMessageCellData *)data {
    [super fillWithData:data];
    
    // Setup loading image view
    [self setupLoadingImageView];
    
    // Always handle loading image visibility based on isFinished state
    if (data.isFinished) {
        [self stopLoadingAnimation];
        _loadingImageView.hidden = YES;
        _loadingImageView.image = nil;
    } else {
        [self startLoadingAnimation];
        _loadingImageView.hidden = NO;
    }
    
    // Online Push text needs streaming display
    if (Msg_Source_OnlinePush == data.source) {
        // Reuse existing timer from data.timer or create new one
        if (data.timer) {
            // Reuse existing timer
            self.currentTimer = data.timer;
        } else {
            // Create new timer only if data.timer is nil
            self.currentTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
            data.timer = self.currentTimer;
            
            NSTimeInterval period = 0.04;
            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, period * NSEC_PER_SEC);
            dispatch_source_set_timer(self.currentTimer, start, period * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
            dispatch_source_set_event_handler(self.currentTimer, ^{
                if (data.displayedContentLength == data.contentString.length) {
                    [self stopTimer:self.currentTimer];
                    self.currentTimer = nil;
                    data.timer = nil;
                    // Send notification when loading animation stops
                    if (data.isFinished) {
                        [self stopLoadingAnimation];
                        self.loadingImageView.hidden = YES;
                    }
                    return;
                }
                data.displayedContentLength++;

                if (self.textView.attributedText.length > 1 &&
                    [self getAttributeStringRect:self.textView.attributedText].size.height >
                    [self getAttributeStringRect:[self.textView.attributedText attributedSubstringFromRange:
                                                  NSMakeRange(0, self.textView.attributedText.length - 1)]].size.height) {
                    [self stopTimer:self.currentTimer];
                    self.currentTimer = nil;
                    data.timer = nil;
                    [self notifyCellSizeChanged];
                } else {
                    UIColor *textColor = self.class.incommingTextColor;
                    UIFont *textFont = self.class.incommingTextFont;
                    if (data.direction == MsgDirectionIncoming) {
                        textColor = self.class.incommingTextColor;
                        textFont = self.class.incommingTextFont;
                    } else {
                        textColor = self.class.outgoingTextColor;
                        textFont = self.class.outgoingTextFont;
                    }
                    
                    // Use original content display method
                    self.textView.attributedText = [data getContentAttributedString:textFont];
                    self.textView.textColor = textColor;
                    self.textView.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;

                    [self updateCellConstraints];
                    
                    // Update loading image position - follow text dynamically
                    [self updateLoadingImageViewLayout];
                    
                    // Always keep loading animation visible during streaming process
                    if (!self.animationDisplayLink) {
                        [self startLoadingAnimation];
                    }
                    self.loadingImageView.hidden = NO;
                }
            });
            dispatch_resume(self.currentTimer);
        }
    } else {
        // Non-streaming display handling
        UIFont *textFont = self.class.incommingTextFont;
        if (data.direction == MsgDirectionOutgoing) {
            textFont = self.class.outgoingTextFont;
        }
        self.textView.attributedText = [data getContentAttributedString:textFont];
        self.textView.textColor = self.class.incommingTextColor;
        self.textView.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;


        // Only update layout if loading image should be visible
        if (!data.isFinished) {
            [self updateLoadingImageViewLayout];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLoadingImageViewLayout];
}

- (void)dealloc {
    [self stopLoadingAnimation];
    
    // Stop current timer
    if (self.currentTimer) {
        [self stopTimer:self.currentTimer];
        self.currentTimer = nil;
        
        // Also clear data.timer
        TUIChatbotMessageCellData *data = (TUIChatbotMessageCellData *)self.bubbleData;
        if (data && [data isKindOfClass:[TUIChatbotMessageCellData class]]) {
            data.timer = nil;
        }
    }
    
    // Remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGRect)getAttributeStringRect:(NSAttributedString *)attributeString {
    return [attributeString boundingRectWithSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT)
            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
}

- (void)stopTimer:(dispatch_source_t)timer {
    if (timer) {
        dispatch_source_cancel(timer);
        timer = nil;
    }
}

- (void)notifyCellSizeChanged {
    NSDictionary *param = @{TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey_Message : self.bubbleData.innerMessage};
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey
                  object:nil
                   param:param];
}

- (void)updateCellConstraints {
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

@end 
