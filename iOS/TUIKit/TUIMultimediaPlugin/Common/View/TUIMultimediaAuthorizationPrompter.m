// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaAuthorizationPrompter.h"
#import <SafariServices/SafariServices.h>
#import "TUIMultimediaPlugin/TUIMultimediaSignatureChecker.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"

#define IM_MULTIMEDIA_PLUGIN_DOCUMENT_URL @"https://cloud.tencent.com/document/product/269/113290"

@interface TUIMultimediaAuthorizationPrompter () {
    UIButton *_confirmButton;
}

@property (nonatomic, copy) void (^dismissHandler)(void);

@end

@implementation TUIMultimediaAuthorizationPrompter

+ (BOOL) verifyPermissionGranted:(UIViewController*)parentView {
    if ([[TUIMultimediaSignatureChecker shareInstance] isFunctionSupport]) {
        return YES;
    }
    NSLog(@"signature checker do not  support function.");
    if (parentView != nil) {
        [TUIMultimediaAuthorizationPrompter showPrompterDialogInViewController:parentView];
    }
    return NO;
}

+ (void)showPrompterDialogInViewController:(UIViewController *)presentingVC {
    TUIMultimediaAuthorizationPrompter *dialog = [[TUIMultimediaAuthorizationPrompter alloc] init];
    dialog.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    dialog.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [presentingVC presentViewController:dialog animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor tertiarySystemBackgroundColor];
    container.layer.cornerRadius = 16;
    container.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:container];
    
    UIStackView *titleStack = [[UIStackView alloc] init];
    titleStack.axis = UILayoutConstraintAxisHorizontal;
    titleStack.spacing = 12;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = [TUIMultimediaCommon localizedStringForKey:@"prompter"];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textColor = [UIColor labelColor];
    [titleStack addArrangedSubview:titleLabel];
    
    UILabel *prompter = [[UILabel alloc] init];
    prompter.numberOfLines = 0;
    prompter.text = [TUIMultimediaCommon localizedStringForKey:@"authorization_prompter"];
    prompter.font = [UIFont systemFontOfSize:14];
    prompter.textColor = [UIColor secondaryLabelColor];
    
    UITextView *prompter_access_docments = [[UITextView alloc] init];
    prompter_access_docments.editable = NO;
    prompter_access_docments.scrollEnabled = NO;
    prompter_access_docments.backgroundColor = [UIColor clearColor];
    prompter_access_docments.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSString* prompter_accessing_documents = [TUIMultimediaCommon localizedStringForKey:@"authorization_prompter_accessing_documents"];
    NSString* documents_title = [TUIMultimediaCommon localizedStringForKey:@"authorization_prompter_documents_title"];
    NSRange title_range = [prompter_accessing_documents rangeOfString:documents_title];
    
    NSMutableAttributedString *linkText = [[NSMutableAttributedString alloc] initWithString:prompter_accessing_documents];
    [linkText addAttribute:NSLinkAttributeName
                    value:IM_MULTIMEDIA_PLUGIN_DOCUMENT_URL
                    range:title_range];
    prompter_access_docments.attributedText = linkText;
    prompter_access_docments.tintColor = [UIColor systemBlueColor];
    prompter_access_docments.font = [UIFont systemFontOfSize:14];
    prompter_access_docments.textColor = [UIColor secondaryLabelColor];
    
    
    UILabel *prompter_remove_module = [[UILabel alloc] init];
    prompter_remove_module.numberOfLines = 0;
    prompter_remove_module.text = [TUIMultimediaCommon localizedStringForKey:@"authorization_prompter_remove_module"];
    prompter_remove_module.font = [UIFont systemFontOfSize:14];
    prompter_remove_module.textColor = [UIColor secondaryLabelColor];
    
    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_confirmButton setTitle:[TUIMultimediaCommon localizedStringForKey:@"ok"] forState:UIControlStateNormal];
    [_confirmButton addTarget:self
                      action:@selector(confirmAction)
            forControlEvents:UIControlEventTouchUpInside];
    _confirmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[
        titleStack, prompter, prompter_access_docments, prompter_remove_module, _confirmButton
    ]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 6;
    stack.alignment = UIStackViewAlignmentLeading;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:stack];
    
    [NSLayoutConstraint activateConstraints:@[
        [container.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [container.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [container.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                           multiplier:0.8],
        
        [stack.topAnchor constraintEqualToAnchor:container.topAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-20],
        [stack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-20],
        
        [_confirmButton.leadingAnchor constraintEqualToAnchor:stack.leadingAnchor]
    ]];
}

- (void)confirmAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView
shouldInteractWithURL:(NSURL *)URL
         inRange:(NSRange)characterRange
     interaction:(UITextItemInteraction)interaction {
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:URL];
    [self presentViewController:safari animated:YES completion:nil];
    return NO;
}

@end
