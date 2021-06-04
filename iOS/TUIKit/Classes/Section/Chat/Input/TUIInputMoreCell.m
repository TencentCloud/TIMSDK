//
//  TMoreCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIInputMoreCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "NSBundle+TUIKIT.h"



static TUIInputMoreCellData *TUI_Photo_MoreCell;
static TUIInputMoreCellData *TUI_Picture_MoreCell;
static TUIInputMoreCellData *TUI_Video_MoreCell;
static TUIInputMoreCellData *TUI_File_MoreCell;
static TUIInputMoreCellData *TUI_VideoCall_MoreCell;
static TUIInputMoreCellData *TUI_AudioCall_MoreCell;
static TUIInputMoreCellData *TUI_GroupLivePlay_MoreCell;

@implementation TUIInputMoreCellData

+ (TUIInputMoreCellData *)pictureData
{
    if (!TUI_Picture_MoreCell) {
        TUI_Picture_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Picture_MoreCell.title = TUILocalizableString(TUIKitMoreCamera);
        TUI_Picture_MoreCell.image = [UIImage tk_imageNamed:@"more_camera"];

    }
    return TUI_Picture_MoreCell;
}

+ (void)setPictureData:(TUIInputMoreCellData *)cameraData
{
    TUI_Picture_MoreCell = cameraData;
}

+ (TUIInputMoreCellData *)photoData
{
    if (!TUI_Photo_MoreCell) {
        TUI_Photo_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Photo_MoreCell.title = TUILocalizableString(TUIKitMorePhoto);
        TUI_Photo_MoreCell.image = [UIImage tk_imageNamed:@"more_picture"];
    }
    return TUI_Photo_MoreCell;
}

+ (void)setPhotoData:(TUIInputMoreCellData *)pictureData
{
    TUI_Photo_MoreCell = pictureData;
}

+ (TUIInputMoreCellData *)videoData
{
    if (!TUI_Video_MoreCell) {
        TUI_Video_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_Video_MoreCell.title = TUILocalizableString(TUIKitMoreVideo);
        TUI_Video_MoreCell.image = [UIImage tk_imageNamed:@"more_video"];
    }
    return TUI_Video_MoreCell;
}

+ (void)setVideoData:(TUIInputMoreCellData *)videoData
{
    TUI_Video_MoreCell = videoData;
}

+ (TUIInputMoreCellData *)fileData
{
    if (!TUI_File_MoreCell) {
        TUI_File_MoreCell = [[TUIInputMoreCellData alloc] init];
        TUI_File_MoreCell.title = TUILocalizableString(TUIKitMoreFile);
        TUI_File_MoreCell.image = [UIImage tk_imageNamed:@"more_file"];
    }
    return TUI_File_MoreCell;
}

+ (void)setFileData:(TUIInputMoreCellData *)fileData
{
    TUI_File_MoreCell = fileData;
}

@end

@implementation TUIInputMoreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    [_title setFont:[UIFont systemFontOfSize:14]];
    [_title setTextColor:[UIColor grayColor]];
    _title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_title];
}

- (void)fillWithData:(TUIInputMoreCellData *)data
{
    //set data
    _data = data;
    _image.image = data.image;
    [_title setText:data.title];
    //update layout
    CGSize menuSize = TMoreCell_Image_Size;
    _image.frame = CGRectMake(0, 0, menuSize.width, menuSize.height);
    _title.frame = CGRectMake(0, _image.frame.origin.y + _image.frame.size.height, _image.frame.size.width + 10, TMoreCell_Title_Height);
    _title.center = CGPointMake(_image.center.x, _title.center.y);
}

+ (CGSize)getSize
{
    CGSize menuSize = TMoreCell_Image_Size;
    return CGSizeMake(menuSize.width, menuSize.height + TMoreCell_Title_Height);
}
@end
