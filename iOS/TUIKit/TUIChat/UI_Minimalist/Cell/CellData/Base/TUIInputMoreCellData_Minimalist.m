
#import "TUIInputMoreCellData_Minimalist.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

static TUIInputMoreCellData_Minimalist *TUI_Photo_MoreCell;
static TUIInputMoreCellData_Minimalist *TUI_Picture_MoreCell;
static TUIInputMoreCellData_Minimalist *TUI_Video_MoreCell;
static TUIInputMoreCellData_Minimalist *TUI_File_MoreCell;
static TUIInputMoreCellData_Minimalist *TUI_VideoCall_MoreCell;
static TUIInputMoreCellData_Minimalist *TUI_AudioCall_MoreCell;

@implementation TUIInputMoreCellData_Minimalist

+ (void)initialize
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeLanguage) name:TUIChangeLanguageNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onChangeTheme) name:TUIDidApplyingThemeChangedNotfication object:nil];
}

+ (void)onChangeLanguage
{
    [self resetAllCelData];
}

+ (void)onChangeTheme
{
    [self resetAllCelData];
}

+ (TUIInputMoreCellData_Minimalist *)pictureData
{
    if (!TUI_Picture_MoreCell) {
        TUI_Picture_MoreCell = [[TUIInputMoreCellData_Minimalist alloc] init];
        TUI_Picture_MoreCell.title = TUIKitLocalizableString(TUIKitMoreCamera);
        TUI_Picture_MoreCell.image = TUIChatBundleThemeImage(@"chat_more_camera_img", @"more_camera");
        TUI_Picture_MoreCell.key = @"TUI_Picture_MoreCell";
    }
    return TUI_Picture_MoreCell;
}

+ (void)setPictureData:(TUIInputMoreCellData_Minimalist *)cameraData
{
    TUI_Picture_MoreCell = cameraData;
}

+ (TUIInputMoreCellData_Minimalist *)photoData
{
    if (!TUI_Photo_MoreCell) {
        TUI_Photo_MoreCell = [[TUIInputMoreCellData_Minimalist alloc] init];
        TUI_Photo_MoreCell.title = TUIKitLocalizableString(TUIKitMorePhoto);
        TUI_Photo_MoreCell.image = TUIChatBundleThemeImage(@"chat_more_picture_img", @"more_picture");
        TUI_Photo_MoreCell.key = @"TUI_Photo_MoreCell";
    }
    return TUI_Photo_MoreCell;
}

+ (void)setPhotoData:(TUIInputMoreCellData_Minimalist *)pictureData
{
    TUI_Photo_MoreCell = pictureData;
}

+ (TUIInputMoreCellData_Minimalist *)videoData
{
    if (!TUI_Video_MoreCell) {
        TUI_Video_MoreCell = [[TUIInputMoreCellData_Minimalist alloc] init];
        TUI_Video_MoreCell.title = TUIKitLocalizableString(TUIKitMoreVideo);
        TUI_Video_MoreCell.image = TUIChatBundleThemeImage(@"chat_more_video_img", @"more_video");
        TUI_Video_MoreCell.key = @"TUI_Video_MoreCell";
    }
    return TUI_Video_MoreCell;
}

+ (void)setVideoData:(TUIInputMoreCellData_Minimalist *)videoData
{
    TUI_Video_MoreCell = videoData;
}

+ (TUIInputMoreCellData_Minimalist *)fileData
{
    if (!TUI_File_MoreCell) {
        TUI_File_MoreCell = [[TUIInputMoreCellData_Minimalist alloc] init];
        TUI_File_MoreCell.title = TUIKitLocalizableString(TUIKitMoreFile);
        TUI_File_MoreCell.image = TUIChatBundleThemeImage(@"chat_more_file_img", @"more_file");
        TUI_File_MoreCell.key = @"TUI_File_MoreCell";
    }
    return TUI_File_MoreCell;
}

+ (void)setFileData:(TUIInputMoreCellData_Minimalist *)fileData
{
    TUI_File_MoreCell = fileData;
}

+ (void)resetAllCelData
{
    TUI_Photo_MoreCell = nil;
    TUI_Picture_MoreCell = nil;
    TUI_Video_MoreCell = nil;
    TUI_File_MoreCell = nil;
    TUI_VideoCall_MoreCell = nil;
    TUI_AudioCall_MoreCell = nil;
}

@end
