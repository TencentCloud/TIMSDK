//
//  PAirSandbox.m
//  AirSandboxDemo
//
//  Created by gao feng on 2017/7/18.
//  Copyright © 2017年 music4kid. All rights reserved.
//

#import "PAirSandbox.h"
#import <UIKit/UIKit.h>

#define ASThemeColor [UIColor colorWithWhite:0.2 alpha:1.0]
#define ASWindowPadding 20

#pragma mark- ASFileItem

typedef enum : NSUInteger {
    ASFileItemUp,
    ASFileItemDirectory,
    ASFileItemFile,
} ASFileItemType;

@interface PAirSandbox ()
@property (nonatomic, strong) NSMutableArray*                   groupItems;
@end

@interface ASFileItem : NSObject
@property (nonatomic, copy) NSString*                 name;
@property (nonatomic, copy) NSString*                 path;
@property (nonatomic, assign) ASFileItemType          type;
@end

@implementation ASFileItem
@end

#pragma mark- ASTableViewCell
@interface PAirSandboxCell : UITableViewCell
@property (nonatomic, strong) UILabel*                 lbName;
@end

@implementation PAirSandboxCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        int cellWidth = [UIScreen mainScreen].bounds.size.width - 2*ASWindowPadding;

        _lbName = [UILabel new];
        _lbName.backgroundColor = [UIColor clearColor];
        _lbName.font = [UIFont systemFontOfSize:13];
        _lbName.textAlignment = NSTextAlignmentLeft;
        _lbName.frame = CGRectMake(10, 30, cellWidth - 20, 15);
        _lbName.textColor = [UIColor blackColor];
        [self addSubview:_lbName];

        UIView* line = [UIView new];
        line.backgroundColor = ASThemeColor;
        line.frame = CGRectMake(10, 47, cellWidth - 20, 1);
        [self addSubview:line];
    }
    return self;
}

- (void)renderWithItem:(ASFileItem*)item
{
    _lbName.text = item.name;
}

@end

#pragma mark- ASViewController
@interface ASViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView*                 tableView;
@property (nonatomic, strong) UIButton*                    btnClose;
@property (nonatomic, strong) NSArray*                     items;
@property (nonatomic, copy) NSString*                      rootPath;
@end

@implementation ASViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self prepareCtrl];
    [self loadPath:nil];
}

- (void)prepareCtrl
{
    self.view.backgroundColor = [UIColor whiteColor];

    _btnClose = [UIButton new];
    [self.view addSubview:_btnClose];
    _btnClose.backgroundColor = ASThemeColor;
    [_btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [_btnClose addTarget:self action:@selector(btnCloseClick) forControlEvents:UIControlEventTouchUpInside];

    _tableView = [UITableView new];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;

    _items = @[];
    _rootPath = NSHomeDirectory();
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    int viewWidth = [UIScreen mainScreen].bounds.size.width - 2*ASWindowPadding;
    int closeWidth = 60;
    int closeHeight = 28;

    _btnClose.frame = CGRectMake(viewWidth-closeWidth-4, 4, closeWidth, closeHeight);

    CGRect tableFrame = self.view.frame;
    tableFrame.origin.y += (closeHeight+4);
    tableFrame.size.height -= (closeHeight+4);
    _tableView.frame = tableFrame;
}

- (void)btnCloseClick
{
    self.view.window.hidden = true;
}

- (void)loadPath:(NSString*)filePath
{
    NSMutableArray* files = @[].mutableCopy;

    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray *groupItems = [PAirSandbox sharedInstance].groupItems;
    for (ASFileItem *groupItem in groupItems) {
        NSString *parent = [groupItem.path stringByDeletingLastPathComponent];
        if ([parent isEqualToString:filePath]) {
            filePath = _rootPath;
            break;
        }
    }

    NSString* targetPath = filePath;
    if (targetPath.length == 0 || [targetPath isEqualToString:_rootPath]) {
        targetPath = _rootPath;
        [files addObjectsFromArray:groupItems];
    }
    else
    {
        ASFileItem* file = [ASFileItem new];
        file.name = @"🔙..";
        file.type = ASFileItemUp;
        file.path = filePath;
        [files addObject:file];
    }

    NSError* err = nil;
    NSArray* paths = [fm contentsOfDirectoryAtPath:targetPath error:&err];
    for (NSString* path in paths) {

        if ([[path lastPathComponent] hasPrefix:@"."]) {
            continue;
        }

        BOOL isDir = false;
        NSString* fullPath = [targetPath stringByAppendingPathComponent:path];
        [fm fileExistsAtPath:fullPath isDirectory:&isDir];

        ASFileItem* file = [ASFileItem new];
        file.path = fullPath;
        if (isDir) {
            file.type = ASFileItemDirectory;
            file.name = [NSString stringWithFormat:@"%@ %@", @"📁", path];
        }
        else
        {
            file.type = ASFileItemFile;
            file.name = [NSString stringWithFormat:@"%@ %@", @"📄", path];
        }
        [files addObject:file];

    }
    _items = files.copy;
    [_tableView reloadData];
}

#pragma mark- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > _items.count-1) {
        return [UITableViewCell new];
    }

    ASFileItem* item = [_items objectAtIndex:indexPath.row];

    static NSString* cellIdentifier = @"PAirSandboxCell";
    PAirSandboxCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[PAirSandboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell renderWithItem:item];

    return cell;
}

#pragma mark- UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > _items.count-1) {
        return;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:false];

    ASFileItem* item = [_items objectAtIndex:indexPath.row];
    if (item.type == ASFileItemUp) {
        [self loadPath:[item.path stringByDeletingLastPathComponent]];
    }
    else if(item.type == ASFileItemFile) {
        [self sharePath:item.path];
    }
    else if(item.type == ASFileItemDirectory) {
        [self loadPath:item.path];
    }
}

- (void)sharePath:(NSString*)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSArray *objectsToShare = @[url];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;

    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        controller.popoverPresentationController.sourceView = self.view;
        controller.popoverPresentationController.sourceRect = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height, 10, 10);
    }
    [self presentViewController:controller animated:YES completion:nil];
}

@end

#pragma mark- PAirSandbox
@interface PAirSandbox ()
@property (nonatomic, strong) UIWindow*                         window;
@property (nonatomic, strong) ASViewController*                 ctrl;
@end

@implementation PAirSandbox

+ (instancetype)sharedInstance
{
    static PAirSandbox* instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [PAirSandbox new];
    });

    return instance;
}

- (void)enableSwipe
{
    UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeDetected:)];
    swipeGesture.numberOfTouchesRequired = 1;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:swipeGesture];
}

- (void)onSwipeDetected:(UISwipeGestureRecognizer*)gs
{
    [self showSandboxBrowser];
}

- (void)showSandboxBrowser {
    if (_window == nil) {
        _window = [UIWindow new];
        CGRect keyFrame = [UIScreen mainScreen].bounds;
        keyFrame.origin.y += 64;
        keyFrame.size.height -= 64;
        _window.frame = CGRectInset(keyFrame, ASWindowPadding, ASWindowPadding);
        _window.backgroundColor = [UIColor whiteColor];
        _window.layer.borderColor = ASThemeColor.CGColor;
        _window.layer.borderWidth = 2.0;
        _window.windowLevel = UIWindowLevelStatusBar;

        _ctrl = [ASViewController new];
        _window.rootViewController = _ctrl;
    }
    _window.hidden = false;
}

- (void)addAppGroup:(NSString *)groupId {
    if (_groupItems == nil) {
        _groupItems = @[].mutableCopy;
    }

    NSURL *groupURL = [[NSFileManager defaultManager]
                       containerURLForSecurityApplicationGroupIdentifier:groupId];

    ASFileItem* file = [ASFileItem new];
    file.path = groupURL.relativePath;
    file.type = ASFileItemDirectory;
    file.name = [NSString stringWithFormat:@"%@ %@", @"📁", groupId];
    [_groupItems addObject:file];
}

@end

