/******************************************************************************
 *
 *  本文件声明了 TUIFileMessageCellData 类。
 *  本类继承于 TUIMessageCellData，用于存放文件消息单元所需的一系列数据与信息。
 *  本文件中已经实现了获取文件信息和相关数据处理的业务逻辑。
 *  当您需要获取文件数据时，直接调用本文件中声明的相关成员函数即可。
 *
 ******************************************************************************/

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 * 【模块名称】TUIFileMessageCellData
 * 【功能说明】文件消息单元。
 *  文件消息单元，即发送/接收文件消息时所使用并显示的消息单元。
 *  文件消息单元数据源则为文件消息单元提供一系列所需数据与消息。
 *  本类中整合调用了 IM SDK，通过 SDK 提供的接口对文件资源进行在线获取。
 *  数据源帮助实现了 MVVM 架构，使数据与 UI 进一步解耦，同时使 UI 层更加细化、可定制化。
 */
@interface TUIFileMessageCellData : TUIMessageCellData

/**
 *  文件存储路径
 */
@property (nonatomic, strong) NSString *path;

/**
 *  文件名称
 *  文件名称包含后缀。
 */
@property (nonatomic, strong) NSString *fileName;

/**
 *  文件内部 ID
 */
@property (nonatomic, strong) NSString *uuid;

/**
 *  文件长度
 *  文件大小，用于展示文件的数据体积信息。
 */
@property (nonatomic, assign) int length;

/**
 *  文件上传进度
 *  在上传过程中，cellData 维护该进度值。
 */
@property (nonatomic, assign) NSUInteger uploadProgress;

/**
 *  文件下载进度
 *  在下载过程中，cellData 维护该进度值。
 */
@property (nonatomic, assign) NSUInteger downladProgress;

/**
 *  下载标识符
 *  YES：正在下载；NO：未在下载
 */
@property (nonatomic, assign) BOOL isDownloading;

/**
 *  下载文件
 *  本函数整合调用了 IM SDK ，通过 SDK 提供的借口在线获取文件。
 *  1、下载文件时，会先判断文件是否在本地，如果在本地则直接读取。
 *  2、当文件不在本地时，判断目前是否正在下在，若正在下载，则等待下载完成，否则通过 IM SDK 提供的接口在线获取。
 *  3-1、下载进度百分比则通过接口回调的 progress（代码块）参数进行更新。
 *  3-2、代码块具有 curSize 和 totalSize 两个参数，由回调函数维护 curSize，然后通过 curSize * 100 / totalSize 计算出当前进度百分比。
 *  4、下载成功后，会生成文件 path 并存储下来。
 */
- (void)downloadFile;

/**
 *  判断文件是否已在本地
 *  本函数会先尝试从本地获取文件 path，若获取成功，记录 path 并返回 YES。否则返回 NO。
 *
 *  @return YES：文件在本地；NO：文件不在本地。
 */
- (BOOL)isLocalExist;


/**
 *  获取文件路径
 *
 *  @param isExist 文件是否在本地存在
 */
- (NSString *)getFilePath:(BOOL *)isExist;

@end

NS_ASSUME_NONNULL_END
