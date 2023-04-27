//
//  TUITranslationLanguageController.m
//  TUITranslation
//
//  Created by xia on 2023/4/7.
//

#import "TUITranslationLanguageController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMConfig.h>
#import "TUITranslationConfig.h"

@interface TUITranslationLanguageController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *languageCodeList;
@property (nonatomic, copy) NSArray *languageNameList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *currentIndex;

@end

@implementation TUITranslationLanguageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = TIMCommonLocalizableString(TranslateMessage);
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView DataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.languageNameList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.languageNameList.count) {
        return nil;
    }
    NSString *language = self.languageNameList[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
    cell.textLabel.text = language;
    if ([language isEqualToString:[TUITranslationConfig defaultConfig].targetLanguageName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.currentIndex = indexPath;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.languageNameList.count || indexPath.row >= self.languageCodeList.count) {
        return;
    }
    if (indexPath.row == self.currentIndex.row) {
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:self.currentIndex];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    self.currentIndex = indexPath;
    
    [TUITranslationConfig defaultConfig].targetLanguageCode = self.languageCodeList[indexPath.row];
    if (self.onSelectedLanguage) {
        self.onSelectedLanguage(self.languageNameList[indexPath.row]);
    }
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.delaysContentTouches = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.rowHeight = 55;
        [_tableView registerClass:[TUICommonTextCell class] forCellReuseIdentifier:@"textCell"];
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

/**
 Simplified Chinese, Traditional Chinese, English, Japanese, Korean, French, Spanish, Italian, German,
 Turkish, Russian, Portuguese, Vietnamese, Indonesian, Thai, Malaysian,
 Hindi language
 */
- (NSArray *)languageNameList {
    return @[@"简体中文", @"繁體中文", @"English", @"日本語", @"한국어", @"Français", @"Español", @"Italiano", @"Deutsch",
             @"Türkçe", @"Русский", @"Português", @"Tiếng Việt", @"Bahasa Indonesia", @"ภาษาไทย", @"Bahasa Melayu",
             @"हिन्दी"];
}

- (NSArray *)languageCodeList {
    return @[@"zh", @"zh-TW",  @"en",  @"ja", @"ko", @"fr", @"es", @"it", @"de",
             @"tr", @"ru", @"pt", @"vi", @"id", @"th", @"ms",
             @"hi"];
}

@end
