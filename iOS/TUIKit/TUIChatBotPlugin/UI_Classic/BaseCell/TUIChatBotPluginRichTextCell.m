//
//  TUIChatBotPluginRichTextCell.m
//  TUIChatBotPlugin
//
//  Created by lynx on 2024/3/1.
//  Copyright © 2024 Tencent. All rights reserved.
//

#import "TUIChatBotPluginRichTextCell.h"
#import <TUIChat/TUITextMessageCell.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>
#import <WebKit/WebKit.h>

@interface TUIChatBotPluginRichTextCell ()<WKNavigationDelegate>
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) UIColor *webViewBkColor;
@property(nonatomic, strong) UIColor *webViewTextColor;
@end

@implementation TUIChatBotPluginRichTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.container addSubview:self.webView];
        self.webViewTextColor = [TUITextMessageCell incommingTextColor];
    }
    return self;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    self.webViewBkColor = nil;
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.body.style.backgroundColor=\"%@\"",
                                      [self hexStringFromColor:self.webViewBkColor]] completionHandler:nil];
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('content').style.color=\"%@\"",
                                      [self hexStringFromColor:self.webViewTextColor]] completionHandler:nil];
}

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        NSString *script = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *wkUserController = [[WKUserContentController alloc] init];
        [wkUserController addUserScript: wkUserScript];
        config.userContentController = wkUserController;
        _webView = [[WKWebView alloc]initWithFrame:self.bounds configuration:config];
        _webView.navigationDelegate = self;
        _webView.backgroundColor = [UIColor clearColor];
        [_webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
        _webView.scrollView.scrollEnabled = NO;
        
        NSString *bundlePath = TUIBundlePath(TUIChatBotPluginBundle,TUIChatBotPluginBundle_Key_Class);
        NSString *path = [bundlePath stringByAppendingPathComponent:@"markdown.html"];
        if (path) {
            NSURL *url = [NSURL fileURLWithPath:path];
            NSURLRequest *requset = [NSURLRequest requestWithURL:url];
            [_webView loadRequest:requset];
        }
    }
    return _webView;
}

- (UIColor *)webViewBkColor {
    if (!_webViewBkColor && self.bubbleView.image) {
        UIImage *image = [self.bubbleView.image.imageAsset imageWithTraitCollection:[UITraitCollection currentTraitCollection]];
        _webViewBkColor = [self colorFromImage:image point:CGPointMake(trunc(10), trunc(10))];
    }
    return _webViewBkColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(10);
        make.top.mas_equalTo(2);
        make.width.mas_equalTo(self.container.mm_w - 10 * 2);
        make.height.mas_equalTo(self.container.mm_h - 2 * 2);
    }];
}

- (void)fillWithData:(TUIChatBotPluginRichTextCellData *)data {
    // set data
    [super fillWithData:data];
    self.webViewData = data;
    [self loadMarkdownContent];
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}

- (void)loadMarkdownContent {
    NSString *content = [self getMarkdownContentWithMarkdowString:self.webViewData.content];
    NSString *js = [NSString stringWithFormat:@"javascript:parseMarkdown(\"%@\",true)", content];
    [self.webView evaluateJavaScript:js completionHandler:nil];
    // Set webview background color
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.body.style.backgroundColor=\"%@\"",
                                      [self hexStringFromColor:self.webViewBkColor]] completionHandler:nil];
    // Set webview text color
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('content').style.color=\"%@\"",
                                      [self hexStringFromColor:self.webViewTextColor]] completionHandler:nil];
    // Webview disables sliding and zooming
    NSString *injectionJSString = @"var script = document.createElement('meta');script.name = 'viewport';"
                                   "script.content=\"width=device-width, user-scalable=no\";"
                                   "document.getElementsByTagName('head')[0].appendChild(script);";
    [self.webView evaluateJavaScript:injectionJSString completionHandler:nil];
}

- (NSString *)getMarkdownContentWithMarkdowString:(NSString *)markdown {
    markdown = [markdown stringByReplacingOccurrencesOfString:@"\r"withString:@""];
    markdown = [markdown stringByReplacingOccurrencesOfString:@"\n"withString:@"\\n"];
    markdown = [markdown stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    markdown = [markdown stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    markdown = [markdown stringByReplacingOccurrencesOfString:@"<br>" withString:@"\\n"];
    return markdown;
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    if ([data isKindOfClass:[TUIChatBotPluginRichTextCellData class]]) {
        return CGSizeMake(TRichTextMessageCell_Width_Max, [(TUIChatBotPluginRichTextCellData *)data cellHeight]);
    }
    return CGSizeZero;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self loadMarkdownContent];
    [self updateCellSize];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self limitUpdateCellSize];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler (WKNavigationActionPolicyAllow);
    }
}

- (void)limitUpdateCellSize {
    uint64_t curTs = [[NSDate date] timeIntervalSince1970];
    uint64_t interval = 1; // s
    if (curTs - self.webViewData.lastUpdateTs >= interval && self.webViewData.lastUpdateTs) {
        self.webViewData.lastUpdateTs = curTs;
        [self updateCellSize];
    } else {
        if (self.webViewData.delayUpdate) {
            return;
        }
        self.webViewData.delayUpdate = YES;
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            [self updateCellSize];
            self.webViewData.delayUpdate = NO;
        });
    }
}

- (void)updateCellSize {
    @weakify(self);
    [self.webView evaluateJavaScript:@"document.body.scrollWidth" completionHandler:^(id _Nullable result,NSError *_Nullable error) {
        CGFloat scrollWidth= [result doubleValue];
        [self.webView evaluateJavaScript:@"document.body.scrollHeight"completionHandler:^(id _Nullable result,NSError*_Nullable error) {
            @strongify(self)
            CGFloat scrollHeight = [result doubleValue];
            CGFloat ratio =  CGRectGetWidth(self.webView.frame) /scrollWidth;
            CGFloat webHeight = scrollHeight * ratio;
            if (self.webViewData.cellHeight != webHeight) {
                self.webViewData.cellHeight = webHeight;
                [self notifyCellSizeChanged];
            }
        }];
    }];
}

- (void)notifyCellSizeChanged {
    NSDictionary *param = @{TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey_Message : self.webViewData.innerMessage};
    [TUICore notifyEvent:TUICore_TUIPluginNotify
                  subKey:TUICore_TUIPluginNotify_PluginViewSizeChangedSubKey
                  object:nil
                   param:param];
}

#pragma mark Util
- (UIColor *)colorFromImage:(UIImage *)image point:(CGPoint)point {
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);

    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -point.x, point.y-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);

    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    if (!color) {
        return @"";
    }
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
