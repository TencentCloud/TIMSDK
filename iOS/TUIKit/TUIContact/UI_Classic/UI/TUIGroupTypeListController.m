//
//  TUIGroupTypeListController.m
//  TUIContact
//
//  Created by wyl on 2022/8/23.
//

#import "TUIGroupTypeListController.h"
#import "UIView+TUILayout.h"
#import "TUICommonModel.h"
#import "TUIDefine.h"

@interface TUIGroupTypeData : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *describeText;
@property (nonatomic, copy) NSString *groupType;
@property (nonatomic, assign) CGFloat cellHeight;
- (void)caculateCellHeight;
@end

@interface TUIGroupTypeCell : UITableViewCell
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UITextView *describeTextView;
@property (nonatomic, assign) CGRect describeTextViewRect;
@property (nonatomic, strong) TUIGroupTypeData *cellData;
- (void)setData:(TUIGroupTypeData *)data;
@end

@implementation TUIGroupTypeData
- (void)caculateCellHeight {
    __block NSString *descStr = self.describeText;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 18;
    if (@available(iOS 9.0, *)) {
        paragraphStyle.allowsDefaultTighteningForTruncation = YES;
    }
    paragraphStyle.alignment = NSTextAlignmentJustified;
    CGRect rect = [descStr boundingRectWithSize:CGSizeMake(Screen_Width - 32, MAXFLOAT)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                     attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                   NSParagraphStyleAttributeName : paragraphStyle }
                                        context:nil];
    
    rect.size.width = ceil(rect.size.width) + 1;
    rect.size.height = ceil(rect.size.height)+ 1;

    CGFloat height = 0;
    
    //Image Height
    height+= 12;
    height+= 40;
    
    //Image Describe Height
    height+= 8;
    height+= rect.size.height;
    height+= 16;

    self.cellHeight = height;
}
@end

@implementation TUIGroupTypeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");

    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    _title.font = [UIFont systemFontOfSize:16];
    _title.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
    _title.numberOfLines = 0;
    [self addSubview:_title];

    [self addSubview:self.describeTextView];
}

- (void)layoutSubviews
{
    self.image.frame = CGRectMake(16, 12, 40, 40);
    
    CGFloat x = _image.frame.origin.x + _image.frame.size.width + 10;
    self.title.frame = CGRectMake(x, 0, self.frame.size.width - x -10, 24);
    self.title.center = CGPointMake(self.title.center.x, self.image.center.y);
    self.describeTextView
        .mm_width(self.mm_w -32)
        .mm_height(_describeTextViewRect.size.height)
        .mm_top(12+ 40 + 8)
        .mm_left(16);
}

- (void)setData:(TUIGroupTypeData *)data
{
    _cellData = data;
    _image.image = data.image;
    _title.text = data.title;
    [self updateRectAndTextForDescribeTextView:self.describeTextView groupType:data.groupType];
}

- (UITextView *)describeTextView {
    if (!_describeTextView) {
       _describeTextView = [[UITextView alloc] init];
       _describeTextView.backgroundColor = [UIColor clearColor];
       _describeTextView.editable = NO;
       _describeTextView.scrollEnabled = NO;
       _describeTextView.textContainerInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    }
    return  _describeTextView;
}


- (void)updateRectAndTextForDescribeTextView:(UITextView *)describeTextView groupType:(NSString *) groupType{
    
    __block NSString *descStr = self.cellData.describeText;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 18;
    if (@available(iOS 9.0, *)) {
        paragraphStyle.allowsDefaultTighteningForTruncation = YES;
    }
    paragraphStyle.alignment = NSTextAlignmentJustified;
    NSDictionary * dictionary = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                  NSForegroundColorAttributeName:[UIColor tui_colorWithHex:@"#888888"],
                                  NSParagraphStyleAttributeName : paragraphStyle
    };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:descStr attributes:dictionary];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [descStr length])];
    self.describeTextView.attributedText = attributedString;
    
    CGRect rect = [descStr boundingRectWithSize:CGSizeMake(Screen_Width - 32, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                               NSParagraphStyleAttributeName : paragraphStyle
                                                            }
                                                    context:nil];
    
    rect.size.width = ceil(rect.size.width)+1;
    rect.size.height = ceil(rect.size.height)+1;
    self.describeTextViewRect = rect;
}

@end

@interface TUIGroupTypeListController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TUINaviBarIndicatorView *titleView;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) UIButton * bottomButton;
@end

@implementation TUIGroupTypeListController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupData];

    [self setupView];

}

- (void)setupData
{
    self.data = [NSMutableArray array];
    
    {
        //work
        TUIGroupTypeData * dataWork = [[TUIGroupTypeData alloc] init];
        dataWork.groupType = GroupType_Work;
        dataWork.image = DefaultGroupAvatarImageByGroupType(GroupType_Work);
        dataWork.title = TUIKitLocalizableString(TUIKitCreatGroupType_Work);
        dataWork.describeText = [NSString stringWithFormat:@"%@%@",TUIKitLocalizableString(TUIKitCreatGroupType_Work_Desc) ,TUIKitLocalizableString(TUIKitCreatGroupType_See_Doc)];
        [dataWork caculateCellHeight];
        [self.data addObject:dataWork];
    }
    
    {
        //Public
        TUIGroupTypeData * dataPublic = [[TUIGroupTypeData alloc] init];
        dataPublic.groupType = GroupType_Public;
        dataPublic.image = DefaultGroupAvatarImageByGroupType(GroupType_Public);
        dataPublic.title = TUIKitLocalizableString(TUIKitCreatGroupType_Public);
        dataPublic.describeText = [NSString stringWithFormat:@"%@%@",TUIKitLocalizableString(TUIKitCreatGroupType_Public_Desc) ,TUIKitLocalizableString(TUIKitCreatGroupType_See_Doc)];
        [dataPublic caculateCellHeight];
        [self.data addObject:dataPublic];
    }
    
    
    {
        //Meeting
        TUIGroupTypeData * dataMeeting = [[TUIGroupTypeData alloc] init];
        dataMeeting.groupType = GroupType_Meeting;
        dataMeeting.image = DefaultGroupAvatarImageByGroupType(GroupType_Meeting);
        dataMeeting.title = TUIKitLocalizableString(TUIKitCreatGroupType_Meeting);
        dataMeeting.describeText = [NSString stringWithFormat:@"%@%@",TUIKitLocalizableString(TUIKitCreatGroupType_Meeting_Desc) ,TUIKitLocalizableString(TUIKitCreatGroupType_See_Doc)];
        [dataMeeting caculateCellHeight];
        [self.data addObject:dataMeeting];
    }
    
    {
        //Community
        TUIGroupTypeData * dataCommunity = [[TUIGroupTypeData alloc] init];
        dataCommunity.groupType = GroupType_Community;
        dataCommunity.image = DefaultGroupAvatarImageByGroupType(GroupType_Community);
        dataCommunity.title = TUIKitLocalizableString(TUIKitCreatGroupType_Community);
        dataCommunity.describeText = [NSString stringWithFormat:@"%@%@",TUIKitLocalizableString(TUIKitCreatGroupType_Community_Desc) ,TUIKitLocalizableString(TUIKitCreatGroupType_See_Doc)];
        [dataCommunity caculateCellHeight];
        [self.data addObject:dataCommunity];
    }

}

- (void)setupView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.frame;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    
    _titleView = [[TUINaviBarIndicatorView alloc] init];
    [_titleView setTitle:TUIKitLocalizableString(ChatsNewGroupText)];
    self.navigationItem.titleView = _titleView;
    self.navigationItem.title = @"";
    
    UIView * bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.mm_w, 140)];
    self.tableView.tableFooterView = bottomView;

    self.bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomView addSubview:self.bottomButton];
    self.bottomButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.bottomButton setTitle:TUIKitLocalizableString(TUIKitCreatGroupType_See_Doc_Simple) forState:UIControlStateNormal];
    [self.bottomButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    self.bottomButton.mm_width(self.view.mm_w - 30).mm_bottom(40).mm__centerX(self.view.mm_w/2.0).mm_height(18);
    [self.bottomButton addTarget:self action:@selector(bottomButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    TUIGroupTypeData *data = self.data[indexPath.section];
    return data.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TUIGroupTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TUIGroupTypeCell"];
    if (cell == nil) {
        cell = [[TUIGroupTypeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TUIGroupTypeCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setData:self.data[indexPath.section]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIGroupTypeData * data =  self.data[indexPath.section];
    if (self.selectCallBack) {
        self.selectCallBack(data.groupType);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)bottomButtonClick {
    NSURL * url = [NSURL URLWithString:@"https://cloud.tencent.com/product/im"];
    [TUITool openLinkWithURL:url];
}

@end
